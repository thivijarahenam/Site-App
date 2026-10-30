"""Project Logbook API endpoints."""

from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.models.account import AccountRole
from app.schemas.logbook import (
    LogbookCommentCreate,
    LogbookCommentResponse,
    LogbookEntryAcknowledge,
    LogbookEntryCreate,
    LogbookEntryResponse,
)
from app.security.dependencies import require_roles
from app.services import logbook_service

router = APIRouter(prefix="/logbook", tags=["logbook"])


@router.post(
    "",
    response_model=LogbookEntryResponse,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(require_roles(AccountRole.ADMIN, AccountRole.SUPERVISOR))],
)
def create_entry(data: LogbookEntryCreate, db: Session = Depends(get_db)) -> LogbookEntryResponse:
    """Create a new project logbook entry (Admin / Supervisor)."""
    return logbook_service.create_logbook_entry(db, data)


@router.get(
    "",
    response_model=list[LogbookEntryResponse],
)
def list_entries(
    site_id: UUID | None = Query(None, description="Filter logbook by project / site UUID"),
    category: str | None = Query(None, description="Filter logbook by category"),
    limit: int = Query(100, ge=1, le=500),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
) -> list[LogbookEntryResponse]:
    """List project logbook entries with optional site and category filters."""
    return logbook_service.list_logbook_entries(
        db, site_id=site_id, category=category, limit=limit, offset=offset
    )


@router.get(
    "/{entry_id}",
    response_model=LogbookEntryResponse,
)
def get_entry(entry_id: UUID, db: Session = Depends(get_db)) -> LogbookEntryResponse:
    """Get full details of a specific logbook entry."""
    return logbook_service.get_logbook_entry(db, entry_id)


@router.post(
    "/{entry_id}/acknowledge",
    response_model=LogbookEntryResponse,
    dependencies=[Depends(require_roles(AccountRole.ADMIN, AccountRole.SUPERVISOR))],
)
def acknowledge_logbook_entry(
    entry_id: UUID, data: LogbookEntryAcknowledge, db: Session = Depends(get_db)
) -> LogbookEntryResponse:
    """Acknowledge a logbook entry (Admin / Supervisor)."""
    return logbook_service.acknowledge_entry(db, entry_id, data)


@router.post(
    "/{entry_id}/comments",
    response_model=LogbookCommentResponse,
    status_code=status.HTTP_201_CREATED,
)
def add_entry_comment(
    entry_id: UUID, data: LogbookCommentCreate, db: Session = Depends(get_db)
) -> LogbookCommentResponse:
    """Add a comment / observation to a logbook entry."""
    return logbook_service.add_comment_to_entry(db, entry_id, data)
