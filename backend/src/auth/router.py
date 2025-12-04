from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from src.app.db import get_async_db
from src.auth import crud
from src.auth.deps import get_current_user
from src.auth.models import User
from src.auth.schema import (LoginRequest, RefreshRequest, SignupRequest,
                             TokenPair, UserOut)

router = APIRouter()


@router.post("/signup", response_model=TokenPair, status_code=status.HTTP_201_CREATED)
async def signup(
    payload: SignupRequest,
    db: AsyncSession = Depends(get_async_db),
):
    existing = await crud.get_user_by_email(db, payload.email)
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Email already registered",
        )
    user = await crud.create_user(db, payload.email, payload.username, payload.password)
    # создать связанный профиль по умолчанию
    await crud.create_profile_for_user(db, user)
    access = crud.create_access_token(user)
    session = await crud.create_session(db, user)
    return TokenPair(access_token=access, refresh_token=session.refresh_token)


@router.post("/login", response_model=TokenPair)
async def login(
    payload: LoginRequest,
    db: AsyncSession = Depends(get_async_db),
):
    user = await crud.get_user_by_email(db, payload.email)
    if not user or not crud.verify_password(payload.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid credentials",
        )
    access = crud.create_access_token(user)
    session = await crud.create_session(db, user)
    return TokenPair(access_token=access, refresh_token=session.refresh_token)


@router.post("/refresh", response_model=TokenPair)
async def refresh(
    payload: RefreshRequest,
    db: AsyncSession = Depends(get_async_db),
):
    session = await crud.get_session_by_token(db, payload.refresh_token)
    if not session:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid refresh token",
        )
    user: User = session.user
    access = crud.create_access_token(user)
    # You could optionally rotate refresh tokens here
    return TokenPair(access_token=access, refresh_token=session.refresh_token)


@router.get("/me", response_model=UserOut)
async def read_current_user(
    current_user: User = Depends(get_current_user),
):
    """
    Возвращает текущего пользователя по Bearer JWT.
    """
    return current_user
