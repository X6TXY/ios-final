import os
from functools import lru_cache

from pydantic import BaseModel


class Settings(BaseModel):
    # Database
    postgres_user: str = os.getenv("POSTGRES_USER", "admin")
    postgres_password: str = os.getenv("POSTGRES_PASSWORD", "admin")
    postgres_db: str = os.getenv("POSTGRES_DB", "movie_app")
    postgres_host: str = os.getenv("POSTGRES_HOST", "localhost")
    postgres_port: int = int(os.getenv("POSTGRES_PORT", "5432"))

    # Redis
    redis_url: str = os.getenv("REDIS_URL", "redis://localhost:6379/0")

    # RabbitMQ (for Celery / tasks)
    rabbitmq_url: str = os.getenv(
        "RABBITMQ_URL", "amqp://guest:guest@rabbitmq:5672//"
    )

    # External APIs
    openai_api_key: str | None = os.getenv("OPENAI_API_KEY")
    openai_model: str = os.getenv("OPENAI_MODEL", "gpt-4o-mini")
    tmdb_api_key: str | None = os.getenv("TMDB_API_KEY", "eyJdocker compose up -d rabbitmqhbGciOiJIUzI1NiJ9.eyJhdWQiOiJjNzI3NzQ3NDE5YzVjMjE2YjdkNWYzMTNkMWIzM2I1YSIsIm5iZiI6MTc2NDg0NTg4NC42NzEsInN1YiI6IjY5MzE2OTNjZWJkZThjMjA0YTMzNzBlYSIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.RvE43TjzWi4ioWVnAFXdFAAaWPZ9q-jv5j5Y0I20BMc")

    # Misc
    app_name: str = os.getenv("APP_NAME", "MovieTinder API")
    environment: str = os.getenv("ENVIRONMENT", "development")

    # Auth / JWT
    jwt_secret: str = os.getenv("JWT_SECRET", "CHANGE_ME_SECRET")
    jwt_algorithm: str = os.getenv("JWT_ALGORITHM", "HS256")
    access_token_expire_minutes: int = int(
        os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "15")
    )

    @property
    def database_url_async(self) -> str:
        """
        Async SQLAlchemy URL (for app runtime).
        """
        return (
            "postgresql+asyncpg://"
            f"{self.postgres_user}:{self.postgres_password}"
            f"@{self.postgres_host}:{self.postgres_port}/{self.postgres_db}"
        )

    @property
    def database_url_sync(self) -> str:
        """
        Sync SQLAlchemy URL (for Alembic migrations).
        """
        return (
            "postgresql+psycopg2://"
            f"{self.postgres_user}:{self.postgres_password}"
            f"@{self.postgres_host}:{self.postgres_port}/{self.postgres_db}"
        )


@lru_cache
def get_settings() -> Settings:
    """
    Cached settings instance so we don't rebuild it on every request.
    """
    return Settings()


