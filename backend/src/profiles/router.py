from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession

from src.app.db import get_async_db
from src.profiles import crud
from src.profiles.schema import ProfileOut, ProfileUpdate

router = APIRouter()


@router.get("/{user_id}", response_model=ProfileOut)
async def get_profile(
    user_id: UUID,
    db: AsyncSession = Depends(get_async_db),
):
    profile = await crud.get_profile_by_user_id(db, user_id)
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    return profile


@router.put("/{user_id}", response_model=ProfileOut)
async def update_profile(
    user_id: UUID,
    payload: ProfileUpdate,
    db: AsyncSession = Depends(get_async_db),
):
    profile = await crud.get_profile_by_user_id(db, user_id)
    if not profile:
        raise HTTPException(status_code=404, detail="Profile not found")
    return await crud.update_profile(db, profile, payload)

