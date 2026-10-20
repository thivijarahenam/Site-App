"""Notification service."""

from uuid import UUID

from sqlalchemy.orm import Session

from app.models.notification import Notification
from app.repositories.notification_repository import (
    count_unread,
    create_notification,
    list_notifications,
    mark_all_read,
    mark_notification_read,
)
from app.schemas.notification import NotificationDetail


def send_notification(
    db: Session,
    recipient_id: UUID,
    title: str,
    message: str,
    notification_type: str,
    reference_id: UUID | None = None,
) -> Notification:
    notif = Notification(
        recipient_id=recipient_id,
        title=title,
        message=message,
        notification_type=notification_type,
        reference_id=reference_id,
    )
    return create_notification(db, notif)


def get_user_notifications(
    db: Session,
    recipient_id: UUID,
    *,
    unread_only: bool = False,
    limit: int = 50,
    offset: int = 0,
) -> list[NotificationDetail]:
    notifs = list_notifications(
        db, recipient_id, unread_only=unread_only, limit=limit, offset=offset
    )
    return [NotificationDetail.model_validate(n) for n in notifs]


def get_unread_count(db: Session, recipient_id: UUID) -> int:
    return count_unread(db, recipient_id)


def mark_read(db: Session, notification_id: UUID, recipient_id: UUID) -> bool:
    success = mark_notification_read(db, notification_id, recipient_id)
    if success:
        db.commit()
    return success


def mark_all_as_read(db: Session, recipient_id: UUID) -> int:
    count = mark_all_read(db, recipient_id)
    db.commit()
    return count
