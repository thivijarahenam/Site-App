"""Persistence operations for System Notifications."""

from uuid import UUID

from sqlalchemy import func, select, update
from sqlalchemy.orm import Session

from app.models.notification import Notification


def create_notification(db: Session, notification: Notification) -> Notification:
    db.add(notification)
    db.flush()
    db.refresh(notification)
    return notification


def list_notifications(
    db: Session,
    recipient_id: UUID,
    *,
    unread_only: bool = False,
    limit: int = 50,
    offset: int = 0,
) -> list[Notification]:
    statement = select(Notification).where(Notification.recipient_id == recipient_id)
    if unread_only:
        statement = statement.where(Notification.is_read.is_(False))
    statement = statement.order_by(Notification.created_at.desc()).offset(offset).limit(limit)
    return list(db.scalars(statement).all())


def count_unread(db: Session, recipient_id: UUID) -> int:
    statement = select(func.count(Notification.id)).where(
        Notification.recipient_id == recipient_id, Notification.is_read.is_(False)
    )
    return db.scalar(statement) or 0


def mark_notification_read(db: Session, notification_id: UUID, recipient_id: UUID) -> bool:
    statement = (
        update(Notification)
        .where(Notification.id == notification_id, Notification.recipient_id == recipient_id)
        .values(is_read=True)
    )
    result = db.execute(statement)
    return result.rowcount > 0


def mark_all_read(db: Session, recipient_id: UUID) -> int:
    statement = (
        update(Notification)
        .where(Notification.recipient_id == recipient_id, Notification.is_read.is_(False))
        .values(is_read=True)
    )
    result = db.execute(statement)
    return result.rowcount
