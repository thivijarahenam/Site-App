"""Project Logbook service matching frontend requirements."""

from datetime import UTC, datetime
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.logbook import LogbookComment, ProjectLogbookEntry
from app.repositories import logbook_repository as repo
from app.repositories.site_repository import get_site
from app.schemas.logbook import (
    LogbookCommentCreate,
    LogbookCommentResponse,
    LogbookEntryAcknowledge,
    LogbookEntryCreate,
    LogbookEntryResponse,
)


def _to_response(entry: ProjectLogbookEntry) -> LogbookEntryResponse:
    return LogbookEntryResponse(
        id=entry.id,
        site_id=entry.site_id,
        entry_date=entry.entry_date,
        author_name=entry.author_name,
        author_role=entry.author_role,
        author_avatar=entry.author_avatar,
        category=entry.category,
        title=entry.title,
        description=entry.description,
        photo_urls=entry.photo_urls or [],
        attachments=entry.attachments or [],
        linked_items=entry.linked_items or [],
        is_acknowledged=entry.is_acknowledged,
        acknowledged_by=entry.acknowledged_by,
        acknowledged_at=entry.acknowledged_at,
        comments=[LogbookCommentResponse.model_validate(c) for c in (entry.comments or [])],
        created_at=entry.created_at,
    )


def create_logbook_entry(db: Session, data: LogbookEntryCreate) -> LogbookEntryResponse:
    site = get_site(db, data.site_id)
    if site is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Construction site not found",
        )

    entry = ProjectLogbookEntry(
        site_id=data.site_id,
        entry_date=data.entry_date or datetime.now(UTC),
        author_name=data.author_name,
        author_role=data.author_role,
        author_avatar=data.author_avatar,
        category=data.category.value if hasattr(data.category, "value") else data.category,
        title=data.title,
        description=data.description,
        photo_urls=data.photo_urls,
        attachments=data.attachments,
        linked_items=data.linked_items,
    )
    entry = repo.create_entry(db, entry)
    db.commit()
    db.refresh(entry)
    return _to_response(entry)


def get_logbook_entry(db: Session, entry_id: UUID) -> LogbookEntryResponse:
    entry = repo.get_entry(db, entry_id)
    if entry is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Logbook entry not found",
        )
    return _to_response(entry)


def list_logbook_entries(
    db: Session,
    *,
    site_id: UUID | None = None,
    category: str | None = None,
    limit: int = 100,
    offset: int = 0,
) -> list[LogbookEntryResponse]:
    entries = repo.list_entries(db, site_id=site_id, category=category, limit=limit, offset=offset)
    return [_to_response(e) for e in entries]


def acknowledge_entry(
    db: Session, entry_id: UUID, data: LogbookEntryAcknowledge
) -> LogbookEntryResponse:
    entry = repo.get_entry(db, entry_id)
    if entry is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Logbook entry not found",
        )
    entry = repo.acknowledge_entry(db, entry, data.acknowledged_by)
    db.commit()
    db.refresh(entry)
    return _to_response(entry)


def add_comment_to_entry(
    db: Session, entry_id: UUID, data: LogbookCommentCreate
) -> LogbookCommentResponse:
    entry = repo.get_entry(db, entry_id)
    if entry is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Logbook entry not found",
        )
    comment = LogbookComment(
        entry_id=entry.id,
        author_name=data.author_name,
        author_role=data.author_role,
        text=data.text,
        avatar_url=data.avatar_url,
    )
    comment = repo.add_comment(db, comment)
    db.commit()
    db.refresh(comment)
    return LogbookCommentResponse.model_validate(comment)
