from math import sqrt
from typing import Iterable, List, Tuple


def _cosine_similarity(a: dict[str, float], b: dict[str, float]) -> float:
    if not a or not b:
        return 0.0
    keys = set(a.keys()) | set(b.keys())
    dot = sum(a.get(k, 0.0) * b.get(k, 0.0) for k in keys)
    na = sqrt(sum(v * v for v in a.values()))
    nb = sqrt(sum(v * v for v in b.values()))
    if na == 0 or nb == 0:
        return 0.0
    return float(dot / (na * nb))


def rank_movies_for_user(
    user_id: str,
    taste_vector: dict,
    candidates: Iterable[dict],
) -> List[Tuple[str, float]]:
    """
    Локальный (бесплатный) ранкер фильмов:
    score = совпадение по жанрам + по ключевым словам + немного popularity/rating.
    """
    genre_weights: dict[str, float] = taste_vector.get("genres", {}) or {}
    kw_weights: dict[str, float] = taste_vector.get("keywords", {}) or {}

    scored: List[Tuple[str, float]] = []
    for c in candidates:
        mid = str(c["movie_id"])
        genres = c.get("genres") or []
        keywords = c.get("keywords") or []
        popularity = float(c.get("popularity") or 0.0)
        rating = float(c.get("rating") or 0.0)

        g_score = sum(genre_weights.get(g, 0.0) for g in genres)
        k_score = sum(kw_weights.get(k, 0.0) for k in keywords)

        base = (rating / 10.0) + (popularity / 100.0)
        score = g_score + 0.5 * k_score + 0.1 * base
        scored.append((mid, float(score)))

    scored.sort(key=lambda x: x[1], reverse=True)
    return scored


def rank_friend_match_for_users(
    user_a_id: str,
    user_b_id: str,
    payload: dict,
) -> float:
    """
    Локальный (бесплатный) ранкер похожести друзей.

    Использует:
    - косинусное сходство по жанрам и keyword-векторам,
    - количество общих любимых фильмов.
    """
    taste_a = payload.get("taste_a") or {}
    taste_b = payload.get("taste_b") or {}

    genres_a: dict[str, float] = taste_a.get("genres", {}) or {}
    genres_b: dict[str, float] = taste_b.get("genres", {}) or {}
    kw_a: dict[str, float] = taste_a.get("keywords", {}) or {}
    kw_b: dict[str, float] = taste_b.get("keywords", {}) or {}

    sim_genres = _cosine_similarity(genres_a, genres_b)
    sim_kw = _cosine_similarity(kw_a, kw_b)

    common_favs = float(payload.get("common_favorites_count", 0) or 0)

    # базовая формула: 0–1
    raw_score = 0.6 * sim_genres + 0.3 * sim_kw + 0.1 * min(common_favs / 10.0, 1.0)
    raw_score = max(0.0, min(raw_score, 1.0))
    return float(raw_score * 100.0)
