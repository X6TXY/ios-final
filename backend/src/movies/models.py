import uuid
from datetime import datetime

from sqlalchemy import (Column, Date, DateTime, Float, ForeignKey, Numeric,
                        Text, UniqueConstraint)
from sqlalchemy.dialects.postgresql import ARRAY, ENUM, JSONB, UUID

from src.app.base import Base

movie_status_enum = ENUM(
    "watching",
    "want_to_watch",
    "completed",
    "dropped",
    name="movie_status",
)

swipe_direction_enum = ENUM(
    "like",
    "dislike",
    name="swipe_direction",
)


class Movie(Base):
    __tablename__ = "movies"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    tmdb_id = Column(Text, unique=True, nullable=True)
    title = Column(Text, nullable=False)
    overview = Column(Text, nullable=True)
    release_date = Column(Date, nullable=True)
    rating = Column(Numeric, nullable=True)
    popularity = Column(Numeric, nullable=True)
    poster_url = Column(Text, nullable=True)
    backdrop_url = Column(Text, nullable=True)
    genres = Column(ARRAY(Text), nullable=True)
    keywords = Column(ARRAY(Text), nullable=True)
    metadata_json = Column("metadata", JSONB, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow)


class Favorite(Base):
    __tablename__ = "favorites"
    __table_args__ = (
        UniqueConstraint("user_id", "movie_id", name="uq_favorites_user_movie"),
    )

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    movie_id = Column(
        UUID(as_uuid=True),
        ForeignKey("movies.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    created_at = Column(DateTime, default=datetime.utcnow)


class Dislike(Base):
    __tablename__ = "dislikes"
    __table_args__ = (
        UniqueConstraint("user_id", "movie_id", name="uq_dislikes_user_movie"),
    )

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    movie_id = Column(
        UUID(as_uuid=True),
        ForeignKey("movies.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    created_at = Column(DateTime, default=datetime.utcnow)


class Status(Base):
    __tablename__ = "statuses"
    __table_args__ = (
        UniqueConstraint("user_id", "movie_id", name="uq_statuses_user_movie"),
    )

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    movie_id = Column(
        UUID(as_uuid=True),
        ForeignKey("movies.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    status = Column(movie_status_enum, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow)


class Swipe(Base):
    __tablename__ = "swipes"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    movie_id = Column(
        UUID(as_uuid=True),
        ForeignKey("movies.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    direction = Column(swipe_direction_enum, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)


class AIRecommendation(Base):
    __tablename__ = "ai_recommendations"
    __table_args__ = (
        UniqueConstraint("user_id", "movie_id", name="uq_ai_recs_user_movie"),
    )

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    movie_id = Column(
        UUID(as_uuid=True),
        ForeignKey("movies.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    score = Column(Float, nullable=False)
    generated_at = Column(DateTime, default=datetime.utcnow)
