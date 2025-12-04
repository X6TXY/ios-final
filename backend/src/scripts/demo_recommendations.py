"""
Небольшой скрипт, который:
- создаёт несколько пользователей,
- раскидывает им лайки/дизлайки/статусы по фильмам,
- пересчитывает taste_vector и рекомендации,
- печатает топ рекомендованных фильмов для каждого пользователя.

Запуск (из контейнера api или локально с настроенным PYTHONPATH):

    python -m src.scripts.demo_recommendations
"""

import asyncio
from uuid import uuid4

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.ai import rank_friend_match_for_users
from src.app.db import AsyncSessionLocal
from src.app.tasks import generate_movie_recommendations, recalc_taste_vector
from src.auth import crud as auth_crud
from src.auth.models import Profile, User
from src.movies.crud import (add_dislike, add_favorite, create_swipe,
                             upsert_status)
from src.movies.models import AIRecommendation, Favorite, Movie


async def _seed_users(db: AsyncSession) -> list[User]:
    users_data = [
        ("u1@example.com", "u1", "pass_u1"),
        ("u2@example.com", "u2", "pass_u2"),
        ("u3@example.com", "u3", "pass_u3"),
    ]
    users: list[User] = []
    for email, username, password in users_data:
        existing = await auth_crud.get_user_by_email(db, email)
        if existing:
            users.append(existing)
            continue
        user = await auth_crud.create_user(db, email, username, password)
        await auth_crud.create_profile_for_user(db, user)
        users.append(user)
    return users


async def _seed_interactions(db: AsyncSession, users: list[User]) -> None:
    # берём первые 60 фильмов как кандидаты
    movies_res = await db.execute(
        select(Movie).order_by(Movie.popularity.desc()).limit(60)
    )
    movies = movies_res.scalars().all()
    if len(movies) < 10:
        print("Недостаточно фильмов в БД; сначала запусти sync_tmdb_movies_full")
        return

    def movies_slice(start: int, end: int) -> list[Movie]:
        return movies[start:end]

    # пользователь 1 — любит популярное
    u1 = users[0]
    for m in movies_slice(0, 10):
        await add_favorite(db, u1.id, m.id)
    for m in movies_slice(10, 15):
        await add_dislike(db, u1.id, m.id)
    for m in movies_slice(0, 5):
        await upsert_status(db, u1.id, m.id, "completed")

    # пользователь 2 — любит более нишевое (хвост списка)
    u2 = users[1]
    for m in movies_slice(20, 35):
        await add_favorite(db, u2.id, m.id)
    for m in movies_slice(35, 40):
        await add_dislike(db, u2.id, m.id)
    for m in movies_slice(20, 30):
        await create_swipe(db, u2.id, m.id, "like")

    # пользователь 3 — смешанный вкус
    u3 = users[2]
    for m in movies_slice(5, 15):
        await add_favorite(db, u3.id, m.id)
    for m in movies_slice(0, 5):
        await add_dislike(db, u3.id, m.id)
    for m in movies_slice(15, 25):
        await upsert_status(db, u3.id, m.id, "watching")

    await db.commit()


async def _recompute_and_print(db: AsyncSession, users: list[User]) -> None:
    # для каждого пользователя ставим таски в очередь и потом читаем результаты
    for user in users:
        print(f"\n=== Рекомендации для {user.email} ===")
        # ставим задачи Celery во внешнего воркера
        recalc_taste_vector.delay(str(user.id))
        generate_movie_recommendations.delay(str(user.id))

    # даём воркеру немного времени отработать
    await asyncio.sleep(5)

    # читаем топ 10 рекомендаций из БД для каждого пользователя
    for user in users:
        rec_res = await db.execute(
            select(AIRecommendation, Movie)
            .join(Movie, AIRecommendation.movie_id == Movie.id)
            .where(AIRecommendation.user_id == user.id)
            .order_by(AIRecommendation.score.desc())
            .limit(10)
        )
        rows = rec_res.all()
        if not rows:
            print("Нет рекомендаций (возможно, мало взаимодействий).")
            continue
        for rec, movie in rows:
            print(
                f"- {movie.title} (score={rec.score:.3f}, "
                f"rating={movie.rating}, popularity={movie.popularity})"
            )


async def _friend_matches_demo(db: AsyncSession, users: list[User]) -> None:
    """
    Локально считаем match-score для всех пар пользователей,
    используя тот же ранкер, что и Celery-таска.
    """
    print("\n=== Match scores (дружеские рекомендации, локально) ===")

    # предзагружаем профили
    prof_res = await db.execute(select(Profile))
    profiles_by_user = {p.user_id: p for p in prof_res.scalars().all()}

    # предзагружаем favorites
    fav_res = await db.execute(select(Favorite))
    favs_by_user: dict[UUID, set] = {}
    for f in fav_res.scalars().all():
        favs_by_user.setdefault(f.user_id, set()).add(f.movie_id)

    for i, u1 in enumerate(users):
        for u2 in users[i + 1 :]:
            p1 = profiles_by_user.get(u1.id)
            p2 = profiles_by_user.get(u2.id)
            if not p1 or not p2:
                continue

            taste_a = p1.taste_vector or {}
            taste_b = p2.taste_vector or {}

            fa = favs_by_user.get(u1.id, set())
            fb = favs_by_user.get(u2.id, set())
            common_favs = fa & fb

            payload = {
                "taste_a": taste_a,
                "taste_b": taste_b,
                "common_favorites_count": len(common_favs),
            }

            score = rank_friend_match_for_users(
                str(u1.id),
                str(u2.id),
                payload,
            )
            print(f"- {u1.email} <-> {u2.email}: similarity={score:.1f}")


async def main() -> None:
    async with AsyncSessionLocal() as db:
        users = await _seed_users(db)
        await _seed_interactions(db, users)
        await _recompute_and_print(db, users)
        await _friend_matches_demo(db, users)


if __name__ == "__main__":
    asyncio.run(main())


