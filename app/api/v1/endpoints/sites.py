"""Construction Sites API endpoints."""

from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.models.account import Account, AccountRole
from app.schemas.labour import LabourDetail
from app.schemas.site import SiteCreate, SiteDetail, SitePublic, SiteUpdate
from app.security.dependencies import require_roles
from app.services.site_service import (
    create_construction_site,
    get_assigned_site_for_labourer,
    get_labourers_at_site,
    get_site_by_id,
    list_construction_sites,
    update_site_by_id,
)

router = APIRouter(prefix="/sites", tags=["sites"])


@router.post(
    "",
    response_model=SiteDetail,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(require_roles(AccountRole.ADMIN, AccountRole.SUPERVISOR))],
)
def create_site(data: SiteCreate, db: Session = Depends(get_db)) -> SiteDetail:
    """Create a new construction site (Admin / Supervisor)."""
    return create_construction_site(db, data)


@router.get(
    "",
    response_model=list[SiteDetail],
    dependencies=[Depends(require_roles(AccountRole.ADMIN, AccountRole.SUPERVISOR))],
)
def list_sites(
    status: str | None = Query(None, description="Filter by status (Active, Completed, On Hold)"),
    search: str | None = Query(None, description="Search by name, project, or client"),
    limit: int = Query(100, ge=1, le=500),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
) -> list[SiteDetail]:
    """List all construction sites with optional filters (Admin / Supervisor)."""
    return list_construction_sites(db, status=status, search=search, limit=limit, offset=offset)


@router.get(
    "/assigned/me",
    response_model=SitePublic | None,
)
def get_my_assigned_site(
    account: Account = Depends(require_roles(AccountRole.LABOUR)),
    db: Session = Depends(get_db),
) -> SitePublic | None:
    """Retrieve the construction site currently assigned to the logged-in Labourer."""
    return get_assigned_site_for_labourer(db, account.id)


@router.get(
    "/{site_id}",
    response_model=SiteDetail,
    dependencies=[Depends(require_roles(AccountRole.ADMIN, AccountRole.SUPERVISOR))],
)
def get_site(site_id: UUID, db: Session = Depends(get_db)) -> SiteDetail:
    """Get site details by ID (Admin / Supervisor)."""
    return get_site_by_id(db, site_id)


@router.patch(
    "/{site_id}",
    response_model=SiteDetail,
    dependencies=[Depends(require_roles(AccountRole.ADMIN, AccountRole.SUPERVISOR))],
)
def update_site(site_id: UUID, data: SiteUpdate, db: Session = Depends(get_db)) -> SiteDetail:
    """Update site information or status (Admin / Supervisor)."""
    return update_site_by_id(db, site_id, data)


@router.get(
    "/{site_id}/labourers",
    response_model=list[LabourDetail],
    dependencies=[Depends(require_roles(AccountRole.ADMIN, AccountRole.SUPERVISOR))],
)
def get_site_labourers(site_id: UUID, db: Session = Depends(get_db)) -> list[LabourDetail]:
    """View all labourers working at a specific site (Admin / Supervisor)."""
    return get_labourers_at_site(db, site_id)
