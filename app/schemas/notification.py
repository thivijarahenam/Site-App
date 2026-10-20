"""Pydantic schemas for System Notifications."""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class NotificationDetail(BaseModel):
    id: UUID
    recipient_id: UUID
    title: str
    message: str
    notification_type: str
    reference_id: UUID | None = None
    is_read: bool
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class UnreadCountResponse(BaseModel):
    unread_count: int
