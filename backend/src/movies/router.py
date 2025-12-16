from typing import Sequence
from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from src.app.db import get_async_db
from src.app.tasks import (generate_movie_recommendations, prepare_swipe_batch,
                           recalc_taste_vector)
from src.auth.deps import get_current_user
from src.auth.models import User
from src.movies import tmdb_client
from src.movies.models import AIRecommendation, Dislike, Favorite, Movie, Swipe

from . import crud
from .schema import (ActivityItem, CastMemberOut, DislikeOut, FavoriteOut,
                     MovieCreate, MovieOut, MovieUpdate, StatusOut,
                     StatusUpdate, SwipeCreate)

router = APIRouter()


@router.get("/", response_model=Sequence[MovieOut])
async def list_movies(
    db: AsyncSession = Depends(get_async_db),
):
    return await crud.list_movies(db)


@router.post(
    "/", response_model=MovieOut, status_code=status.HTTP_201_CREATED
)
async def create_movie(
    payload: MovieCreate,
    db: AsyncSession = Depends(get_async_db),
):
    return await crud.create_movie(db, payload)


@router.get("/by-id/{movie_id}", response_model=MovieOut)
async def get_movie(
    movie_id: UUID,
    db: AsyncSession = Depends(get_async_db),
):
    movie: Movie | None = await crud.get_movie(db, movie_id)
    if movie is None:
        raise HTTPException(status_code=404, detail="Movie not found")
    return movie


@router.put("/by-id/{movie_id}", response_model=MovieOut)
async def update_movie(
    movie_id: UUID,
    payload: MovieUpdate,
    db: AsyncSession = Depends(get_async_db),
):
    movie: Movie | None = await crud.get_movie(db, movie_id)
    if movie is None:
        raise HTTPException(status_code=404, detail="Movie not found")
    return await crud.update_movie(db, movie, payload)


@router.delete(
    "/by-id/{movie_id}", status_code=status.HTTP_204_NO_CONTENT
)
async def delete_movie(
    movie_id: UUID,
    db: AsyncSession = Depends(get_async_db),
):
    movie: Movie | None = await crud.get_movie(db, movie_id)
    if movie is None:
        raise HTTPException(status_code=404, detail="Movie not found")
    await crud.delete_movie(db, movie)
    return None


@router.get("/recommendations", response_model=Sequence[MovieOut])
async def get_recommendations(
    limit: int = 20,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_async_db),
):
    """
    Получить рекомендованные фильмы для текущего пользователя
    из таблицы ai_recommendations.
    """
    stmt = (
        select(Movie)
        .join(AIRecommendation, AIRecommendation.movie_id == Movie.id)
        .where(AIRecommendation.user_id == current_user.id)
        .order_by(AIRecommendation.score.desc())
        .limit(limit)
    )
    res = await db.execute(stmt)
    return res.scalars().all()


@router.get("/activity", response_model=Sequence[ActivityItem])
async def get_my_activity(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_async_db),
):
    """
    Лента активности по свайпам текущего пользователя.
    Берём swipes (like/dislike) и подтягиваем фильмы.
    """
    stmt = (
        select(Movie, Swipe.direction, Swipe.created_at)
        .join(Swipe, Swipe.movie_id == Movie.id)
        .where(Swipe.user_id == current_user.id)
        .order_by(Swipe.created_at.desc())
    )
    res = await db.execute(stmt)
    rows = res.all()

    items: list[ActivityItem] = []
    for m, direction, created_at in rows:
        movie_out = MovieOut.model_validate(m, from_attributes=True)
        items.append(
            ActivityItem(
                movie=movie_out,
                direction=direction,
                created_at=created_at,
            )
        )

    return items


@router.get("/{movie_id}/cast", response_model=Sequence[CastMemberOut])
async def get_movie_cast(
    movie_id: UUID,
    db: AsyncSession = Depends(get_async_db),
):
    """
    Состав актёров для фильма по его UUID.
    Берём tmdb_id из БД и тянем credits из TMDB.
    """
    movie = await crud.get_movie(db, movie_id)
    if movie is None or not movie.tmdb_id:
        raise HTTPException(status_code=404, detail="Movie not found or missing tmdb_id")

    try:
        tmdb_id_int = int(movie.tmdb_id)
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid tmdb_id")

    credits = tmdb_client.fetch_movie_credits(tmdb_id_int)
    cast = credits.get("cast", [])[:10]

    base_image_url = "https://image.tmdb.org/t/p/w185"

    result: list[CastMemberOut] = []
    for member in cast:
        profile_path = member.get("profile_path")
        profile_url = f"{base_image_url}{profile_path}" if profile_path else None
        result.append(
            CastMemberOut(
                name=member.get("name") or "",
                character=member.get("character"),
                profile_url=profile_url,
            )
        )

    return result


@router.get("/swipe-batch", response_model=Sequence[MovieOut])
async def get_swipe_batch(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_async_db),
):
    """
    Получить предзагруженный набор фильмов для свайпов из Redis.
    """
    from src.app.redis import get_redis_client

    redis_client = get_redis_client()
    redis_key = f"swipe_batch:{current_user.id}"

    # LTRIM + LRANGE для атомарного получения и очистки списка
    async with redis_client.pipeline() as pipe:
        pipe.lrange(redis_key, 0, -1)
        pipe.delete(redis_key)
        results = await pipe.execute()
        movie_ids_str = results[0]

    if not movie_ids_str:
        # Если в Redis пусто, запрашиваем генерацию нового батча на фоне
        prepare_swipe_batch.delay(str(current_user.id))
        # И возвращаем пустой список
        return []

    movie_ids = [UUID(m_id) for m_id in movie_ids_str]

    # Загружаем полные объекты фильмов из БД
    stmt = select(Movie).where(Movie.id.in_(movie_ids))
    res = await db.execute(stmt)
    movies = res.scalars().all()

    # Сохраняем исходный порядок из Redis
    movie_map = {m.id: m for m in movies}
    ordered_movies = [movie_map[m_id] for m_id in movie_ids if m_id in movie_map]

    return ordered_movies


@router.post(
    "/{movie_id}/favorites",
    response_model=FavoriteOut,
    status_code=status.HTTP_201_CREATED,
)
async def add_favorite_movie(
    movie_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_async_db),
):
    movie = await crud.get_movie(db, movie_id)
    if movie is None:
        raise HTTPException(status_code=404, detail="Movie not found")

    fav = await crud.add_favorite(db, current_user.id, movie_id)

    # триггерим пересчёт taste-вектора и рекомендаций
    recalc_taste_vector.delay(str(current_user.id))
    generate_movie_recommendations.delay(str(current_user.id))
    prepare_swipe_batch.delay(str(current_user.id))

    return fav


@router.delete(
    "/{movie_id}/favorites",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def remove_favorite_movie(
    movie_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_async_db),
):
    await crud.remove_favorite(db, current_user.id, movie_id)
    recalc_taste_vector.delay(str(current_user.id))
    generate_movie_recommendations.delay(str(current_user.id))
    prepare_swipe_batch.delay(str(current_user.id))
    return None


@router.post(
    "/{movie_id}/dislikes",
    response_model=DislikeOut,
    status_code=status.HTTP_201_CREATED,
)
async def add_dislike_movie(
    movie_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_async_db),
):
    movie = await crud.get_movie(db, movie_id)
    if movie is None:
        raise HTTPException(status_code=404, detail="Movie not found")

    dislike = await crud.add_dislike(db, current_user.id, movie_id)
    recalc_taste_vector.delay(str(current_user.id))
    generate_movie_recommendations.delay(str(current_user.id))
    prepare_swipe_batch.delay(str(current_user.id))
    return dislike


@router.delete(
    "/{movie_id}/dislikes",
    status_code=status.HTTP_204_NO_CONTENT,
)
async def remove_dislike_movie(
    movie_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_async_db),
):
    await crud.remove_dislike(db, current_user.id, movie_id)
    recalc_taste_vector.delay(str(current_user.id))
    generate_movie_recommendations.delay(str(current_user.id))
    prepare_swipe_batch.delay(str(current_user.id))
    return None


@router.put(
    "/{movie_id}/status",
    response_model=StatusOut,
)
async def update_movie_status(
    movie_id: UUID,
    payload: StatusUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_async_db),
):
    movie = await crud.get_movie(db, movie_id)
    if movie is None:
        raise HTTPException(status_code=404, detail="Movie not found")

    status_row = await crud.upsert_status(
        db,
        current_user.id,
        movie_id,
        payload.status,
    )
    recalc_taste_vector.delay(str(current_user.id))
    generate_movie_recommendations.delay(str(current_user.id))
    prepare_swipe_batch.delay(str(current_user.id))
    return status_row


@router.post(
    "/{movie_id}/swipes",
    status_code=status.HTTP_201_CREATED,
)
async def create_movie_swipe(
    movie_id: UUID,
    payload: SwipeCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_async_db),
):
    if payload.user_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="user_id must be current user",
        )

    movie = await crud.get_movie(db, movie_id)
    if movie is None:
        raise HTTPException(status_code=404, detail="Movie not found")

    swipe = await crud.create_swipe(
        db,
        current_user.id,
        movie_id,
        payload.direction,
    )

    # swipe "like" влияет на вкус
    if payload.direction == "like":
        recalc_taste_vector.delay(str(current_user.id))
        generate_movie_recommendations.delay(str(current_user.id))
        prepare_swipe_batch.delay(str(current_user.id))

    return swipe


