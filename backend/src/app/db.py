from typing import AsyncGenerator

from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine
from sqlalchemy.orm import sessionmaker

from src.app.base import Base
from src.app.config import get_settings

settings = get_settings()


engine = create_async_engine(
    settings.database_url_async,
    echo=False,
    future=True,
)

AsyncSessionLocal = sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,
)


async def get_async_db() -> AsyncGenerator[AsyncSession, None]:
    """
    FastAPI dependency that provides an `AsyncSession`.
    """
    async with AsyncSessionLocal() as session:
        yield session

