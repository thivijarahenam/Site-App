"""Persistence operations for project logbook entries and comments."""

from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import select
from sqlalchemy.orm import Session, selectinload

from app.models.logbook import LogbookComment, ProjectLogbookEntry


def create_entry(db: Session, entry: ProjectLogbookEntry) -> ProjectLogbookEntry:
    db.add(entry)
    db.flush()
    return entry


def get_entry(db: Session, entry_id: UUID) -> ProjectLogbookEntry | None:
    statement = (
        select(ProjectLogbookEntry)
        .where(ProjectLogbookEntry.id == entry_id)
        .options(selectinload(ProjectLogbookEntry.comments))
    )
    return db.scalar(statement)


def list_entries(
    db: Session,
    *,
    site_id: UUID | None = None,
    category: str | None = None,
    limit: int = 100,
    offset: int = 0,
) -> list[ProjectLogbookEntry]:
    statement = (
        select(ProjectLogbookEntry)
        .options(selectinload(ProjectLogbookEntry.comments))
        .order_by(ProjectLogbookEntry.entry_date.desc())
    )
    if site_id is not None:
        statement = statement.where(ProjectLogbookEntry.site_id == site_id)
    if category is not None:
        statement = statement.where(ProjectLogbookEntry.category == category)
    statement = statement.limit(limit).offset(offset)
    return list(db.scalars(statement).all())


def acknowledge_entry(
    db: Session, entry: ProjectLogbookEntry, acknowledged_by: str
) -> ProjectLogbookEntry:
    entry.is_acknowledged = True
    entry.acknowledged_by = acknowledged_by
    entry.acknowledged_at = datetime.now(UTC)
    db.flush()
    return entry


def add_comment(db: Session, comment: LogbookComment) -> LogbookComment:
    db.add(comment)
    db.flush()
    return comment
