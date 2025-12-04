from fastapi import Depends, FastAPI, HTTPException
from sqlalchemy import text
from sqlalchemy.exc import OperationalError
from sqlalchemy.ext.asyncio import AsyncSession

from src.app.config import get_settings
from src.app.db import get_async_db
from src.app.redis import close_redis, get_redis_client
from src.app.tasks import celery_app
from src.auth.router import router as auth_router
from src.friends.router import router as friends_router
from src.movies.router import router as movies_router
from src.profiles.router import router as profiles_router

settings = get_settings()

app = FastAPI(title=settings.app_name)


@app.on_event("shutdown")
async def shutdown_event() -> None:
    await close_redis()


@app.get("/health")
async def check_health(db: AsyncSession = Depends(get_async_db)):
    """
    Simple healthcheck that verifies DB and Redis connections.
    """
    # Check DB
    try:
        await db.execute(text("SELECT 1"))
    except OperationalError:
        raise HTTPException(status_code=500, detail="Database connection failed")

    # Check Redis
    redis_client = get_redis_client()
    try:
        await redis_client.ping()
    except Exception:
        raise HTTPException(status_code=500, detail="Redis connection failed")

    # Check Celery broker (optional – don't fail health if broker is down)
    try:
        celery_ok = celery_app.control.inspect().ping() is not None
    except Exception:
        celery_ok = False

    return {
        "status": "ok",
        "database": "connected",
        "redis": "connected",
        "celery": "connected" if celery_ok else "unreachable",
    }


# Routers
app.include_router(auth_router, prefix="/auth", tags=["auth"])
app.include_router(movies_router, prefix="/movies", tags=["movies"])
app.include_router(profiles_router, prefix="/profiles", tags=["profiles"])
app.include_router(friends_router, prefix="/friends", tags=["friends"])