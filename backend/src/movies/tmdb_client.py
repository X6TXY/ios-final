from typing import Any, Dict, List

import httpx
from src.app.config import get_settings

settings = get_settings()


def _get_auth_headers() -> Dict[str, str]:
    """
    Build TMDB auth headers.

    Prefer TMDB_API_KEY (v3) from env, but also support passing a full
    v4 access token in TMDB_API_TOKEN if you want to use that style.
    """
    token = getattr(settings, "tmdb_api_key", None)
    if not token:
        raise RuntimeError("TMDB_API_KEY is not configured")

    # If it's clearly a JWT-like token, treat it as a Bearer token
    if token.startswith("eyJ"):
        return {
            "Authorization": f"Bearer {token}",
            "accept": "application/json",
        }

    # Otherwise assume it's v3 API key – we'll pass it as query param
    # and leave Authorization empty.
    return {
        "accept": "application/json",
    }


def _client() -> httpx.Client:
    return httpx.Client(
        base_url="https://api.themoviedb.org/3",
        headers=_get_auth_headers(),
        timeout=15,
    )


def search_movie(
    query: str, language: str = "en-US", region: str | None = None
) -> Dict[str, Any]:
    """
    Simple wrapper for /search/movie (synchronous; good enough for Celery jobs).
    """
    params: Dict[str, Any] = {"query": query, "language": language}
    if region:
        params["region"] = region

    with _client() as client:
        resp = client.get("/search/movie", params=params)
        resp.raise_for_status()
        return resp.json()


def fetch_popular_movies(
    page: int = 1, language: str = "en-US"
) -> Dict[str, Any]:
    with _client() as client:
        resp = client.get(
            "/movie/popular",
            params={"page": page, "language": language},
        )
        resp.raise_for_status()
        return resp.json()


def fetch_trending_movies(window: str = "day") -> Dict[str, Any]:
    with _client() as client:
        resp = client.get(f"/trending/movie/{window}")
        resp.raise_for_status()
        return resp.json()


def fetch_movie_details(
    movie_id: int, language: str = "en-US"
) -> Dict[str, Any]:
    with _client() as client:
        resp = client.get(f"/movie/{movie_id}", params={"language": language})
        resp.raise_for_status()
        return resp.json()


def fetch_movie_credits(movie_id: str) -> Dict[str, Any]:
    """
    Wrapper for /movie/{movie_id}/credits.
    """
    with _client() as client:
        resp = client.get(f"/movie/{movie_id}/credits")
        resp.raise_for_status()
        return resp.json()

def fetch_movie_keywords(movie_id: int) -> List[Dict[str, Any]]:
    with _client() as client:
        resp = client.get(f"/movie/{movie_id}/keywords")
        resp.raise_for_status()
        data = resp.json()
        return data.get("keywords", [])


def discover_movies_by_year(
    year: int, page: int = 1, language: str = "en-US"
) -> Dict[str, Any]:
    """
    Wrapper for /discover/movie with фильтрацией по году.
    """
    with _client() as client:
        resp = client.get(
            "/discover/movie",
            params={
                "sort_by": "popularity.desc",
                "primary_release_year": year,
                "page": page,
                "language": language,
            },
        )
        resp.raise_for_status()
        return resp.json()

