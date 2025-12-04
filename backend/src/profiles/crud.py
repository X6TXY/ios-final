from typing import Optional
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.auth.models import Profile
from src.profiles.schema import ProfileUpdate


async def get_profile_by_user_id(
    db: AsyncSession, user_id: UUID
) -> Optional[Profile]:
    result = await db.execute(
        select(Profile).where(Profile.user_id == user_id)
    )
    return result.scalar_one_or_none()


async def update_profile(
    db: AsyncSession, profile: Profile, data: ProfileUpdate
) -> Profile:
    for field, value in data.model_dump(exclude_unset=True).items():
        setattr(profile, field, value)
    await db.commit()
    await db.refresh(profile)
    return profile


