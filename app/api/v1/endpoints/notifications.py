"""Notifications API endpoints."""

from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.models.account import Account
from app.schemas.notification import NotificationDetail, UnreadCountResponse
from app.security.dependencies import get_current_account
from app.services.notification_service import (
    get_unread_count,
    get_user_notifications,
    mark_all_as_read,
    mark_read,
)

router = APIRouter(prefix="/notifications", tags=["notifications"])


@router.get("", response_model=list[NotificationDetail])
def list_my_notifications(
    unread_only: bool = Query(False, description="Filter only unread notifications"),
    limit: int = Query(50, ge=1, le=200),
    offset: int = Query(0, ge=0),
    account: Account = Depends(get_current_account),
    db: Session = Depends(get_db),
) -> list[NotificationDetail]:
    """Retrieve notifications for the authenticated user."""
    return get_user_notifications(
        db, account.id, unread_only=unread_only, limit=limit, offset=offset
    )


@router.get("/unread-count", response_model=UnreadCountResponse)
def get_my_unread_count(
    account: Account = Depends(get_current_account),
    db: Session = Depends(get_db),
) -> UnreadCountResponse:
    """Get the number of unread notifications for the current user."""
    count = get_unread_count(db, account.id)
    return UnreadCountResponse(unread_count=count)


@router.post("/{notification_id}/read", status_code=status.HTTP_200_OK)
def mark_as_read(
    notification_id: UUID,
    account: Account = Depends(get_current_account),
    db: Session = Depends(get_db),
) -> dict[str, str]:
    """Mark a notification as read."""
    mark_read(db, notification_id, account.id)
    return {"status": "ok"}


@router.post("/read-all", status_code=status.HTTP_200_OK)
def mark_all_read(
    account: Account = Depends(get_current_account),
    db: Session = Depends(get_db),
) -> dict[str, int]:
    """Mark all notifications as read."""
    count = mark_all_as_read(db, account.id)
    return {"marked_read": count}
