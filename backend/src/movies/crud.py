from datetime import date
from typing import Any, Dict, Sequence
from uuid import UUID

from sqlalchemy import and_, select
from sqlalchemy.ext.asyncio import AsyncSession

from src.movies.models import (AIRecommendation, Dislike, Favorite, Movie,
                               Status, Swipe)
from src.movies.schema import MovieCreate, MovieUpdate


def _extract_genres(tmdb_data: Dict[str, Any]) -> list[str] | None:
    genres = tmdb_data.get("genres") or []
    return [g.get("name") for g in genres if g.get("name")]


def _extract_keywords(keywords_data: Dict[str, Any]) -> list[str] | None:
    return [k.get("name") for k in keywords_data if k.get("name")]


async def upsert_movie_from_tmdb(
    db: AsyncSession,
    tmdb_movie: Dict[str, Any],
    keywords: list[Dict[str, Any]] | None = None,
) -> Movie:
    """
    Create or update a Movie row from TMDB JSON payload.
    """
    tmdb_id = str(tmdb_movie["id"])
    result = await db.execute(select(Movie).where(Movie.tmdb_id == tmdb_id))
    existing = result.scalar_one_or_none()

    genres = _extract_genres(tmdb_movie)
    kw_list = _extract_keywords(keywords or [])

    # TMDB release_date приходит строкой YYYY-MM-DD → конвертируем в date
    release_date_raw = tmdb_movie.get("release_date") or None
    release_date: date | None = None
    if release_date_raw:
        try:
            release_date = date.fromisoformat(release_date_raw)
        except ValueError:
            release_date = None

    poster_path = tmdb_movie.get("poster_path")
    backdrop_path = tmdb_movie.get("backdrop_path")

    payload = {
        "tmdb_id": tmdb_id,
        "title": tmdb_movie.get("title") or tmdb_movie.get("name"),
        "overview": tmdb_movie.get("overview"),
        "release_date": release_date,
        "rating": tmdb_movie.get("vote_average"),
        "popularity": tmdb_movie.get("popularity"),
        "poster_url": f"https://image.tmdb.org/t/p/w500{poster_path}" if poster_path else None,
        "backdrop_url": f"https://image.tmdb.org/t/p/w500{backdrop_path}" if backdrop_path else None,
        "genres": genres,
        "keywords": kw_list,
        "metadata_json": tmdb_movie,
    }

    if existing:
        for field, value in payload.items():
            setattr(existing, field, value)
        await db.commit()
        await db.refresh(existing)
        return existing

    movie = Movie(**payload)
    db.add(movie)
    await db.commit()
    await db.refresh(movie)
    return movie


async def get_movie(db: AsyncSession, movie_id: UUID) -> Movie | None:
    result = await db.execute(select(Movie).where(Movie.id == movie_id))
    return result.scalar_one_or_none()


async def list_movies(db: AsyncSession) -> Sequence[Movie]:
    result = await db.execute(select(Movie))
    return result.scalars().all()


async def create_movie(db: AsyncSession, data: MovieCreate) -> Movie:
    movie = Movie(**data.model_dump())
    db.add(movie)
    await db.commit()
    await db.refresh(movie)
    return movie


async def update_movie(
    db: AsyncSession,
    movie: Movie,
    data: MovieUpdate,
) -> Movie:
    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(movie, field, value)
    await db.commit()
    await db.refresh(movie)
    return movie


async def delete_movie(db: AsyncSession, movie: Movie) -> None:
    await db.delete(movie)
    await db.commit()


# Favorites / dislikes -----------------------------------------------------


async def add_favorite(
    db: AsyncSession, user_id: UUID, movie_id: UUID
) -> Favorite:
    # idempotent: не создаём дубликат, если уже есть такая пара user/movie
    result = await db.execute(
        select(Favorite).where(
            and_(Favorite.user_id == user_id, Favorite.movie_id == movie_id)
        )
    )
    existing = result.scalar_one_or_none()
    if existing:
        return existing

    fav = Favorite(user_id=user_id, movie_id=movie_id)
    db.add(fav)
    await db.commit()
    await db.refresh(fav)
    return fav


async def remove_favorite(
    db: AsyncSession, user_id: UUID, movie_id: UUID
) -> None:
    result = await db.execute(
        select(Favorite).where(
            and_(
                Favorite.user_id == user_id,
                Favorite.movie_id == movie_id,
            )
        )
    )
    fav = result.scalar_one_or_none()
    if fav:
        await db.delete(fav)
        await db.commit()


async def add_dislike(
    db: AsyncSession, user_id: UUID, movie_id: UUID
) -> Dislike:
    result = await db.execute(
        select(Dislike).where(
            and_(Dislike.user_id == user_id, Dislike.movie_id == movie_id)
        )
    )
    existing = result.scalar_one_or_none()
    if existing:
        return existing

    d = Dislike(user_id=user_id, movie_id=movie_id)
    db.add(d)
    await db.commit()
    await db.refresh(d)
    return d


async def remove_dislike(
    db: AsyncSession, user_id: UUID, movie_id: UUID
) -> None:
    result = await db.execute(
        select(Dislike).where(
            and_(
                Dislike.user_id == user_id,
                Dislike.movie_id == movie_id,
            )
        )
    )
    d = result.scalar_one_or_none()
    if d:
        await db.delete(d)
        await db.commit()


# Statuses -----------------------------------------------------------------


async def upsert_status(
    db: AsyncSession, user_id: UUID, movie_id: UUID, status_value: str
) -> Status:
    result = await db.execute(
        select(Status).where(
            and_(
                Status.user_id == user_id,
                Status.movie_id == movie_id,
            )
        )
    )
    s = result.scalar_one_or_none()
    if s:
        s.status = status_value
        await db.commit()
        await db.refresh(s)
        return s

    s = Status(user_id=user_id, movie_id=movie_id, status=status_value)
    db.add(s)
    await db.commit()
    await db.refresh(s)
    return s


# Swipes -------------------------------------------------------------------


async def create_swipe(
    db: AsyncSession, user_id: UUID, movie_id: UUID, direction: str
) -> Swipe:
    swipe = Swipe(user_id=user_id, movie_id=movie_id, direction=direction)
    db.add(swipe)
    await db.commit()
    await db.refresh(swipe)
    return swipe
