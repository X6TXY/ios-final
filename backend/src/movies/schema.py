from datetime import date, datetime
from uuid import UUID

from pydantic import BaseModel


class MovieBase(BaseModel):
    title: str
    overview: str | None = None
    release_date: date | None = None
    rating: float | None = None
    popularity: float | None = None
    poster_url: str | None = None
    backdrop_url: str | None = None


class MovieCreate(MovieBase):
    tmdb_id: str | None = None
    genres: list[str] | None = None
    keywords: list[str] | None = None


class MovieUpdate(BaseModel):
    title: str | None = None
    overview: str | None = None
    release_date: date | None = None
    rating: float | None = None
    popularity: float | None = None
    poster_url: str | None = None
    backdrop_url: str | None = None


class MovieOut(MovieBase):
    id: UUID
    tmdb_id: str | None = None
    genres: list[str] | None = None
    keywords: list[str] | None = None

    class Config:
        from_attributes = True


class FavoriteOut(BaseModel):
    id: UUID
    user_id: UUID
    movie_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True


class DislikeOut(BaseModel):
    id: UUID
    user_id: UUID
    movie_id: UUID
    created_at: datetime

    class Config:
        from_attributes = True


class StatusUpdate(BaseModel):
    status: str


class StatusOut(BaseModel):
    id: UUID
    user_id: UUID
    movie_id: UUID
    status: str
    updated_at: datetime

    class Config:
        from_attributes = True


class SwipeCreate(BaseModel):
    user_id: UUID
    direction: str
