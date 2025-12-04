import uuid
from datetime import datetime

from sqlalchemy import Column, DateTime, Float, ForeignKey, UniqueConstraint
from sqlalchemy.dialects.postgresql import ENUM, UUID

from src.app.base import Base

friend_status_enum = ENUM(
    "pending",
    "accepted",
    "blocked",
    name="friend_status",
)


class Friend(Base):
    __tablename__ = "friends"
    __table_args__ = (
        UniqueConstraint(
            "requester_id",
            "addressee_id",
            name="uq_friends_requester_addressee",
        ),
    )

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    requester_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    addressee_id = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    status = Column(friend_status_enum, nullable=False, default="pending")
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow)


class MatchScore(Base):
    __tablename__ = "match_scores"
    __table_args__ = (
        UniqueConstraint("user_a", "user_b", name="uq_match_scores_pair"),
    )

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_a = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    user_b = Column(
        UUID(as_uuid=True),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    similarity_score = Column(Float, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow)


