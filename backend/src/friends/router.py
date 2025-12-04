from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import and_, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from src.app.db import get_async_db
from src.app.tasks import calculate_friend_match
from src.auth.deps import get_current_user
from src.auth.models import Profile, User
from src.friends import crud
from src.friends.models import Friend, MatchScore
from src.friends.schema import (FriendCreate, FriendOut, FriendSuggestionOut,
                                MatchScoreOut)

router = APIRouter()


@router.get("/", response_model=list[FriendOut])
async def list_friends(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_async_db),
):
    """
    Список друзей для текущего авторизованного пользователя.
    """
    return await crud.list_friends_for_user(db, current_user.id)


@router.get("/requests", response_model=list[FriendOut])
async def list_friend_requests(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_async_db),
):
    """
    Входящие запросы в друзья для текущего пользователя.
    """
    return await crud.list_pending_requests_for_user(db, current_user.id)


@router.post(
    "/requests",
    response_model=FriendOut,
    status_code=status.HTTP_201_CREATED,
)
async def create_friend_request(
    payload: FriendCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_async_db),
):
    """
    Создать запрос в друзья от текущего пользователя к другому.
    """
    if payload.requester_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="requester_id must be current user",
        )

    existing = await crud.get_friend_relation(
        db, payload.requester_id, payload.addressee_id
    )
    if existing:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Friend request already exists",
        )
    return await crud.create_friend_request(
        db, payload.requester_id, payload.addressee_id
    )


@router.post("/{friend_id}/accept", response_model=FriendOut)
async def accept_friend_request(
    friend_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_async_db),
):
    """
    Принять заявку в друзья – может только адресат заявки.
    """
    friend: Friend | None = await crud.get_friend_by_id(db, friend_id)
    if not friend:
        raise HTTPException(status_code=404, detail="Friend request not found")
    if friend.addressee_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Only addressee can accept this request",
        )

    friend = await crud.update_friend_status(db, friend, "accepted")
    calculate_friend_match.delay(
        str(friend.requester_id), str(friend.addressee_id)
    )
    return friend


@router.post("/{friend_id}/block", response_model=FriendOut)
async def block_friend(
    friend_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_async_db),
):
    """
    Заблокировать пользователя – может любой участник связи.
    """
    friend: Friend | None = await crud.get_friend_by_id(db, friend_id)
    if not friend:
        raise HTTPException(status_code=404, detail="Friend relation not found")
    if current_user.id not in (friend.requester_id, friend.addressee_id):
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Not allowed to modify this relation",
        )
    return await crud.update_friend_status(db, friend, "blocked")


@router.get("/suggestions", response_model=list[FriendSuggestionOut])
async def friend_suggestions(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_async_db),
):
    """
    Рекомендации / рейтинг «совместимости» друзей для текущего пользователя.

    Идея:
    - берём все match_scores, где участвует current_user;
    - фильтруем уже существующие связи в friends (accepted/blocked/pending),
      чтобы не предлагать тех, с кем уже есть отношение;
    - для каждого кандидата берём user + профиль, вытаскиваем top-3 жанра
      из taste_vector.genres.
    """
    # все связи, где участвует текущий пользователь
    fr_res = await db.execute(
        select(Friend).where(
            or_(
                Friend.requester_id == current_user.id,
                Friend.addressee_id == current_user.id,
            )
        )
    )
    relations = fr_res.scalars().all()
    excluded_ids: set[UUID] = {current_user.id}
    for fr in relations:
        excluded_ids.add(fr.requester_id)
        excluded_ids.add(fr.addressee_id)

    # match_scores, где участвует текущий пользователь
    ms_res = await db.execute(
        select(MatchScore).where(
            or_(
                MatchScore.user_a == current_user.id,
                MatchScore.user_b == current_user.id,
            )
        )
    )
    scores = ms_res.scalars().all()

    suggestions: list[FriendSuggestionOut] = []

    for ms in sorted(
        scores, key=lambda m: m.similarity_score, reverse=True
    ):
        other_id = ms.user_b if ms.user_a == current_user.id else ms.user_a
        if other_id in excluded_ids:
            continue

        # подгружаем пользователя и профиль
        user_res = await db.execute(select(User).where(User.id == other_id))
        other = user_res.scalar_one_or_none()
        if not other:
            continue

        prof_res = await db.execute(
            select(Profile).where(Profile.user_id == other_id)
        )
        prof = prof_res.scalar_one_or_none()

        top_genres: list[str] = []
        if prof and prof.taste_vector:
            genres = prof.taste_vector.get("genres") or {}
            top_genres = [
                g for g, _ in sorted(
                    genres.items(), key=lambda kv: kv[1], reverse=True
                )[:3]
            ]

        suggestions.append(
            FriendSuggestionOut(
                user_id=other.id,
                username=other.username,
                email=other.email,
                similarity_score=ms.similarity_score,
                top_genres=top_genres,
            )
        )

    return suggestions

