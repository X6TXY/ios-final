from typing import Optional

from redis import asyncio as redis_async

from src.app.config import get_settings

settings = get_settings()

_redis_client: Optional[redis_async.Redis] = None


def get_redis_client() -> redis_async.Redis:
    """
    Lazily create and return a global async Redis client.
    """
    global _redis_client
    if _redis_client is None:
        _redis_client = redis_async.from_url(settings.redis_url)
    return _redis_client


async def close_redis() -> None:
    """
    Gracefully close the redis connection (used on shutdown).
    """
    global _redis_client
    if _redis_client is not None:
        await _redis_client.close()
        _redis_client = None


