from typing import Sequence
from uuid import UUID

from sqlalchemy import and_, or_, select
from sqlalchemy.ext.asyncio import AsyncSession

from src.friends.models import Friend, MatchScore


async def create_friend_request(
    db: AsyncSession, requester_id: UUID, addressee_id: UUID
) -> Friend:
    friend = Friend(
        requester_id=requester_id,
        addressee_id=addressee_id,
    )
    db.add(friend)
    await db.commit()
    await db.refresh(friend)
    return friend


async def get_friend_relation(
    db: AsyncSession, requester_id: UUID, addressee_id: UUID
) -> Friend | None:
    stmt = select(Friend).where(
        and_(
            Friend.requester_id == requester_id,
            Friend.addressee_id == addressee_id,
        )
    )
    result = await db.execute(stmt)
    return result.scalar_one_or_none()


async def get_friend_by_id(db: AsyncSession, friend_id: UUID) -> Friend | None:
    result = await db.execute(select(Friend).where(Friend.id == friend_id))
    return result.scalar_one_or_none()


async def list_friends_for_user(
    db: AsyncSession, user_id: UUID
) -> Sequence[Friend]:
    stmt = select(Friend).where(
        and_(
            Friend.status == "accepted",
            or_(
                Friend.requester_id == user_id,
                Friend.addressee_id == user_id,
            ),
        )
    )
    result = await db.execute(stmt)
    return result.scalars().all()


async def list_pending_requests_for_user(
    db: AsyncSession, user_id: UUID
) -> Sequence[Friend]:
    stmt = select(Friend).where(
        and_(
            Friend.status == "pending",
            Friend.addressee_id == user_id,
        )
    )
    result = await db.execute(stmt)
    return result.scalars().all()


async def update_friend_status(
    db: AsyncSession, friend: Friend, status: str
) -> Friend:
    friend.status = status
    await db.commit()
    await db.refresh(friend)
    return friend


async def upsert_match_score(
    db: AsyncSession, user_a: UUID, user_b: UUID, similarity_score: float
) -> MatchScore:
    # ensure ordering so (a,b) and (b,a) map to same row
    a, b = sorted([user_a, user_b], key=lambda x: str(x))
    stmt = select(MatchScore).where(
        and_(MatchScore.user_a == a, MatchScore.user_b == b)
    )
    result = await db.execute(stmt)
    existing = result.scalar_one_or_none()
    if existing:
        existing.similarity_score = similarity_score
        await db.commit()
        await db.refresh(existing)
        return existing

    ms = MatchScore(user_a=a, user_b=b, similarity_score=similarity_score)
    db.add(ms)
    await db.commit()
    await db.refresh(ms)
    return ms


