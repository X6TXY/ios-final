import uuid
from datetime import datetime, timedelta

from sqlalchemy import Column, Date, DateTime, ForeignKey, Text
from sqlalchemy.dialects.postgresql import JSONB, UUID
from sqlalchemy.orm import relationship

from src.app.base import Base


class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(Text, unique=True, nullable=False, index=True)
    password_hash = Column(Text, nullable=False)
    username = Column(Text, unique=True, nullable=False, index=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    profile = relationship("Profile", back_populates="user", uselist=False)
    sessions = relationship("Session", back_populates="user")


class Profile(Base):
    __tablename__ = "profiles"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    avatar_url = Column(Text, nullable=True)
    bio = Column(Text, nullable=True)
    location = Column(Text, nullable=True)
    birthdate = Column(Date, nullable=True)
    # JSON taste vector for recommendations (genres/keywords/embeddings)
    taste_vector = Column(JSONB, nullable=True)
    updated_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="profile")


class Session(Base):
    __tablename__ = "sessions"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    refresh_token = Column(Text, nullable=False, index=True)
    expires_at = Column(DateTime, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="sessions")

    @staticmethod
    def expiry_from_now(minutes: int) -> datetime:
        return datetime.utcnow() + timedelta(minutes=minutes)

