from datetime import datetime
from uuid import UUID

from pydantic import BaseModel


class FriendBase(BaseModel):
    requester_id: UUID
    addressee_id: UUID


class FriendCreate(FriendBase):
    pass


class FriendOut(FriendBase):
    id: UUID
    status: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class MatchScoreOut(BaseModel):
    id: UUID
    user_a: UUID
    user_b: UUID
    similarity_score: float
    updated_at: datetime

    class Config:
        from_attributes = True


class FriendSuggestionOut(BaseModel):
    user_id: UUID
    username: str
    email: str
    similarity_score: float
    top_genres: list[str]

