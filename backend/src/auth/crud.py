import uuid
from typing import Optional
from uuid import UUID

from passlib.context import CryptContext
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from src.app.config import get_settings
from src.auth.models import Profile, Session, User

pwd_context = CryptContext(schemes=["pbkdf2_sha256"], deprecated="auto")
settings = get_settings()


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(password: str, hashed: str) -> bool:
    return pwd_context.verify(password, hashed)


async def get_user_by_email(
    db: AsyncSession, email: str
) -> Optional[User]:
    result = await db.execute(select(User).where(User.email == email))
    return result.scalar_one_or_none()


async def get_user_by_id(
    db: AsyncSession, user_id: UUID
) -> Optional[User]:
    result = await db.execute(select(User).where(User.id == user_id))
    return result.scalar_one_or_none()


async def create_user(
    db: AsyncSession, email: str, username: str, password: str
) -> User:
    user = User(
        email=email,
        username=username,
        password_hash=hash_password(password),
    )
    db.add(user)
    await db.commit()
    await db.refresh(user)
    return user


async def create_profile_for_user(
    db: AsyncSession, user: User
) -> Profile:
    """
    Создать пустой профиль для только что созданного пользователя.
    """
    profile = Profile(user_id=user.id)
    db.add(profile)
    await db.commit()
    await db.refresh(profile)
    return profile


def create_access_token(user: User) -> str:
    from datetime import datetime, timedelta, timezone

    import jwt

    expire = datetime.now(timezone.utc) + timedelta(
        minutes=settings.access_token_expire_minutes
    )
    payload = {
        "sub": str(user.id),
        "exp": expire,
    }
    return jwt.encode(
        payload,
        settings.jwt_secret,
        algorithm=settings.jwt_algorithm,
    )


async def create_session(
    db: AsyncSession, user: User
) -> Session:
    refresh_token = str(uuid.uuid4())
    session = Session(
        user_id=user.id,
        refresh_token=refresh_token,
        expires_at=Session.expiry_from_now(
            minutes=settings.access_token_expire_minutes * 96  # ~24h*4
        ),
    )
    db.add(session)
    await db.commit()
    await db.refresh(session)
    return session


async def get_session_by_token(
    db: AsyncSession, refresh_token: str
) -> Optional[Session]:
    result = await db.execute(
        select(Session).where(Session.refresh_token == refresh_token)
    )
    return result.scalar_one_or_none()


