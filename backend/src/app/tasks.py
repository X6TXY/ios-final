from uuid import UUID

from celery import Celery
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession, async_sessionmaker

from src.ai import rank_friend_match_for_users, rank_movies_for_user
from src.app.config import get_settings
from src.app.db import engine
from src.auth.models import Profile, User
from src.friends.crud import upsert_match_score
from src.movies import tmdb_client
from src.movies.crud import upsert_movie_from_tmdb
from src.movies.models import (AIRecommendation, Dislike, Favorite, Movie,
                               Status, Swipe)

settings = get_settings()

celery_app = Celery(
    "movie_tinder_tasks",
    broker=settings.rabbitmq_url,
    backend=settings.redis_url,
)

SessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
)


@celery_app.task(queue="taste_update_queue")
def recalc_taste_vector(user_id: str) -> None:
    """
    Background job: recompute user's taste vector based on favorites,
    dislikes, statuses, and swipes.

    Compute a very simple taste vector for the user based on favorites,
    dislikes, statuses and swipes, and store it in Profile.taste_vector.
    """

    async def _run() -> None:
        async with SessionLocal() as session:
            try:
                uid = UUID(user_id)
            except ValueError:
                return

            # ORM-запрос, чтобы получить именно объект Profile,
            # а не "сырую" Row, иначе присвоение profile.taste_vector не сохранится.
            profile_q = await session.execute(
                select(Profile).where(Profile.user_id == uid)
            )
            profile = profile_q.scalar_one_or_none()

            if profile is None:
                # no profile – nothing to do
                return

            # collect user interactions
            fav_q = await session.execute(
                Favorite.__table__.select().where(Favorite.user_id == uid)
            )
            favs = fav_q.fetchall()

            dis_q = await session.execute(
                Dislike.__table__.select().where(Dislike.user_id == uid)
            )
            dis = dis_q.fetchall()

            status_q = await session.execute(
                Status.__table__.select().where(Status.user_id == uid)
            )
            statuses = status_q.fetchall()

            swipe_q = await session.execute(
                Swipe.__table__.select().where(Swipe.user_id == uid)
            )
            swipes = swipe_q.fetchall()

            # build sets of movie ids per type
            fav_ids = {row.movie_id for row in favs}
            dis_ids = {row.movie_id for row in dis}
            status_map = {row.movie_id: row.status for row in statuses}
            swipe_map = {row.movie_id: row.direction for row in swipes}

            # fetch all referenced movies
            all_movie_ids = (
                fav_ids | dis_ids | set(status_map.keys()) | set(swipe_map.keys())
            )
            if not all_movie_ids:
                profile.taste_vector = None
                await session.commit()
                return

            movies_q = await session.execute(
                select(Movie).where(Movie.id.in_(list(all_movie_ids)))
            )
            movies = movies_q.scalars().all()

            genre_scores: dict[str, float] = {}
            keyword_scores: dict[str, float] = {}

            def bump(counter: dict[str, float], items, weight: float) -> None:
                for name in items or []:
                    counter[name] = counter.get(name, 0.0) + weight

            for m in movies:
                mid = m.id
                # base weights
                if mid in fav_ids:
                    bump(genre_scores, m.genres, 3.0)
                    bump(keyword_scores, m.keywords, 2.0)
                if mid in dis_ids:
                    bump(genre_scores, m.genres, -2.0)
                    bump(keyword_scores, m.keywords, -1.5)
                if mid in status_map:
                    status_val = status_map[mid]
                    if status_val == "completed":
                        bump(genre_scores, m.genres, 2.0)
                    elif status_val == "watching":
                        bump(genre_scores, m.genres, 1.0)
                if mid in swipe_map and swipe_map[mid] == "like":
                    bump(genre_scores, m.genres, 1.5)
                    bump(keyword_scores, m.keywords, 1.0)

            profile.taste_vector = {
                "genres": genre_scores,
                "keywords": keyword_scores,
            }
            await session.commit()

    import asyncio

    asyncio.run(_run())


@celery_app.task(queue="movie_recommendation_queue")
def generate_movie_recommendations(user_id: str) -> None:
    """
    Background job: call LLM to rank movies and store in ai_recommendations.

    Use LLM to rank movies for a user and store them in ai_recommendations.
    """

    async def _run() -> None:
        async with SessionLocal() as session:
            try:
                uid = UUID(user_id)
            except ValueError:
                return

            # load profile + taste vector (ORM object, не Row)
            prof_q = await session.execute(
                select(Profile).where(Profile.user_id == uid)
            )
            profile = prof_q.scalar_one_or_none()
            if profile is None or not profile.taste_vector:
                return

            taste_vector = profile.taste_vector

            # get seen movie ids: считаем "просмотренными" только лайки и дизлайки,
            # чтобы всегда оставались кандидаты, даже если пользователь много свайпал/ставил статусы
            fav_ids = {
                row.movie_id
                for row in (
                    await session.execute(
                        Favorite.__table__.select().where(Favorite.user_id == uid)
                    )
                ).fetchall()
            }
            dis_ids = {
                row.movie_id
                for row in (
                    await session.execute(
                        Dislike.__table__.select().where(Dislike.user_id == uid)
                    )
                ).fetchall()
            }

            seen_ids = fav_ids | dis_ids

            # candidate movies: топ по популярности, которых ещё не видел
            cand_q = await session.execute(
                Movie.__table__.select().order_by(Movie.popularity.desc()).limit(500)
            )
            all_cands = cand_q.fetchall()
            candidates = [m for m in all_cands if m.id not in seen_ids][:200]

            if not candidates:
                return

            cand_payload = [
                {
                    "movie_id": str(m.id),
                    "title": m.title,
                    "overview": m.overview,
                    "genres": m.genres or [],
                    "keywords": m.keywords or [],
                    "popularity": float(m.popularity or 0),
                    "rating": float(m.rating or 0),
                }
                for m in candidates
            ]

            rankings = rank_movies_for_user(str(uid), taste_vector, cand_payload)

            # upsert into AIRecommendation
            for mid_str, score in rankings:
                mid = UUID(mid_str)
                rec_q = await session.execute(
                    AIRecommendation.__table__.select().where(
                        (AIRecommendation.user_id == uid)
                        & (AIRecommendation.movie_id == mid)
                    )
                )
                existing = rec_q.scalar_one_or_none()
                now = datetime.utcnow()
                if existing:
                    existing.score = score
                    existing.generated_at = now
                else:
                    rec = AIRecommendation(
                        user_id=uid, movie_id=mid, score=score, generated_at=now
                    )
                    session.add(rec)

            await session.commit()

    import asyncio
    from datetime import datetime

    asyncio.run(_run())


@celery_app.task(queue="friend_match_queue")
def calculate_friend_match(user_a_id: str, user_b_id: str) -> None:
    """
    Background job: recompute similarity between two users and store
    in match_scores.

    Compute similarity between two users using LLM and store in match_scores.
    """

    async def _run() -> None:
        async with SessionLocal() as session:
            try:
                ua = UUID(user_a_id)
                ub = UUID(user_b_id)
            except ValueError:
                return

            # load profiles
            pa_q = await session.execute(
                Profile.__table__.select().where(Profile.user_id == ua)
            )
            pa = pa_q.scalar_one_or_none()
            pb_q = await session.execute(
                Profile.__table__.select().where(Profile.user_id == ub)
            )
            pb = pb_q.scalar_one_or_none()

            if pa is None or pb is None:
                return

            # simple payload: taste vectors + counts of overlaps
            taste_a = pa.taste_vector or {}
            taste_b = pb.taste_vector or {}

            # common favorites
            fa = {
                row.movie_id
                for row in (
                    await session.execute(
                        Favorite.__table__.select().where(Favorite.user_id == ua)
                    )
                ).fetchall()
            }
            fb = {
                row.movie_id
                for row in (
                    await session.execute(
                        Favorite.__table__.select().where(Favorite.user_id == ub)
                    )
                ).fetchall()
            }
            common_favs = list(fa & fb)

            payload = {
                "taste_a": taste_a,
                "taste_b": taste_b,
                "common_favorites_count": len(common_favs),
            }

            score = rank_friend_match_for_users(
                str(ua),
                str(ub),
                payload,
            )

            await upsert_match_score(session, ua, ub, float(score))

    import asyncio

    asyncio.run(_run())


@celery_app.task(queue="tmdb_sync_queue")
def sync_tmdb_movies(pages: int = 3) -> None:
    """
    Background job: sync popular + trending movies from TMDB into local DB.

    - Fetches several pages of popular movies.
    - Fetches trending movies.
    - For each movie, pulls details + keywords and upserts into Postgres.
    """

    async def _run() -> None:
        async with SessionLocal() as session:
            # Popular movies
            for page in range(1, pages + 1):
                popular = tmdb_client.fetch_popular_movies(page=page)
                for item in popular.get("results", []):
                    movie_id = item["id"]
                    details = tmdb_client.fetch_movie_details(movie_id)
                    keywords = tmdb_client.fetch_movie_keywords(movie_id)
                    await upsert_movie_from_tmdb(session, details, keywords)

            # Trending movies (day)
            trending = tmdb_client.fetch_trending_movies(window="day")
            for item in trending.get("results", []):
                movie_id = item["id"]
                details = tmdb_client.fetch_movie_details(movie_id)
                keywords = tmdb_client.fetch_movie_keywords(movie_id)
                await upsert_movie_from_tmdb(session, details, keywords)

    import asyncio

    asyncio.run(_run())


@celery_app.task(queue="tmdb_sync_queue")
def sync_tmdb_movies_full(
    start_year: int = 1980,
    end_year: int = 2025,
    pages_per_year: int = 10,
) -> None:
    """
    Залить большую базу фильмов:
    - идём по годам от start_year до end_year
    - для каждого года запрашиваем discover/movie по pages_per_year страниц.
    """

    from src.movies import tmdb_client

    async def _run() -> None:
        async with SessionLocal() as session:
            for year in range(start_year, end_year + 1):
                for page in range(1, pages_per_year + 1):
                    data = tmdb_client.discover_movies_by_year(
                        year=year, page=page
                    )
                    for item in data.get("results", []):
                        movie_id = item["id"]
                        details = tmdb_client.fetch_movie_details(movie_id)
                        keywords = tmdb_client.fetch_movie_keywords(movie_id)
                        await upsert_movie_from_tmdb(session, details, keywords)

    import asyncio

    asyncio.run(_run())


@celery_app.task(queue="preload_swipe_queue")
def prepare_swipe_batch(user_id: str) -> None:
    """
    Background job: precompute 20 swipeable movies for the user and
    store them in Redis so the iOS client can quickly fetch them.

    NOTE: left as a placeholder – implement Redis queueing as needed.
    """
    return None

