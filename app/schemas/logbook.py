"""Pydantic schemas for Project Logbook Entries and Comments."""

from datetime import datetime
from typing import Any
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

from app.models.logbook import LogbookCategory


class LogbookAttachmentSchema(BaseModel):
    name: str
    size: str
    extension: str
    url: str | None = None


class LogbookCommentCreate(BaseModel):
    author_name: str = Field(..., min_length=2, max_length=200)
    author_role: str = Field(..., min_length=2, max_length=100)
    text: str = Field(..., min_length=1)
    avatar_url: str | None = None


class LogbookCommentResponse(BaseModel):
    id: UUID
    author_name: str
    author_role: str
    text: str
    avatar_url: str | None = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class LogbookEntryCreate(BaseModel):
    site_id: UUID
    author_name: str = Field(..., min_length=2, max_length=200)
    author_role: str = Field(..., min_length=2, max_length=100)
    author_avatar: str | None = None
    category: LogbookCategory = LogbookCategory.GENERAL_NOTE
    title: str = Field(..., min_length=2, max_length=255)
    description: str = Field(..., min_length=2)
    entry_date: datetime | None = None
    photo_urls: list[str] = []
    attachments: list[dict[str, Any]] = []
    linked_items: list[str] = []


class LogbookEntryAcknowledge(BaseModel):
    acknowledged_by: str = Field(..., min_length=2, max_length=200)


class LogbookEntryResponse(BaseModel):
    id: UUID
    site_id: UUID
    entry_date: datetime
    author_name: str
    author_role: str
    author_avatar: str | None = None
    category: str
    title: str
    description: str
    photo_urls: list[str] = []
    attachments: list[dict[str, Any]] = []
    linked_items: list[str] = []
    is_acknowledged: bool = False
    acknowledged_by: str | None = None
    acknowledged_at: datetime | None = None
    comments: list[LogbookCommentResponse] = []
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)
