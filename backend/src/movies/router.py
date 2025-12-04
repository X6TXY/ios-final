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
from src.movies.models import AIRecommendation, Movie

from . import crud
from .schema import (DislikeOut, FavoriteOut, MovieCreate, MovieOut,
                     MovieUpdate, StatusOut, StatusUpdate, SwipeCreate)

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


@router.get("/{movie_id}", response_model=MovieOut)
async def get_movie(
    movie_id: UUID,
    db: AsyncSession = Depends(get_async_db),
):
    movie: Movie | None = await crud.get_movie(db, movie_id)
    if movie is None:
        raise HTTPException(status_code=404, detail="Movie not found")
    return movie


@router.put("/{movie_id}", response_model=MovieOut)
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
    "/{movie_id}", status_code=status.HTTP_204_NO_CONTENT
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


