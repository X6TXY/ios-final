from datetime import date, datetime
from uuid import UUID

from pydantic import BaseModel


class ProfileBase(BaseModel):
    avatar_url: str | None = None
    bio: str | None = None
    location: str | None = None
    birthdate: date | None = None


class ProfileUpdate(ProfileBase):
    pass


class ProfileOut(ProfileBase):
    id: UUID
    user_id: UUID
    updated_at: datetime

    class Config:
        from_attributes = True


