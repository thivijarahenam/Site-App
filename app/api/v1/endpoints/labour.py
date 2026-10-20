"""Labour Management API endpoints."""

from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.models.account import Account, AccountRole
from app.schemas.labour import (
    LabourAssignSite,
    LabourCreate,
    LabourDetail,
    LabourSelfUpdate,
    LabourUpdate,
)
from app.security.dependencies import require_roles
from app.services.labour_service import (
    assign_site,
    create_labourer,
    get_labourer,
    get_labourer_by_account,
    list_all_labourers,
    update_labourer,
    update_self_labour_profile,
)

router = APIRouter(prefix="/labour", tags=["labour"])


@router.post(
    "",
    response_model=LabourDetail,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(require_roles(AccountRole.ADMIN))],
)
def create_labour_profile(data: LabourCreate, db: Session = Depends(get_db)) -> LabourDetail:
    """Create a new Labour account and profile (Admin only)."""
    return create_labourer(db, data)


@router.get(
    "",
    response_model=list[LabourDetail],
    dependencies=[Depends(require_roles(AccountRole.ADMIN))],
)
def list_labourers(
    site_id: UUID | None = Query(None, description="Filter labourers by assigned site"),
    status: str | None = Query(None, description="Filter by status (Active, Inactive, On Leave)"),
    job_role: str | None = Query(None, description="Filter by job role"),
    search: str | None = Query(None, description="Search by name, NIC, or phone"),
    limit: int = Query(100, ge=1, le=500),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
) -> list[LabourDetail]:
    """List all registered labourers with filters (Admin only)."""
    return list_all_labourers(
        db,
        site_id=site_id,
        status=status,
        job_role=job_role,
        search=search,
        limit=limit,
        offset=offset,
    )


@router.get("/me", response_model=LabourDetail)
def get_own_profile(
    account: Account = Depends(require_roles(AccountRole.LABOUR)),
    db: Session = Depends(get_db),
) -> LabourDetail:
    """Get the profile of the currently logged-in Labourer."""
    return get_labourer_by_account(db, account.id)


@router.patch("/me", response_model=LabourDetail)
def update_own_profile(
    data: LabourSelfUpdate,
    account: Account = Depends(require_roles(AccountRole.LABOUR)),
    db: Session = Depends(get_db),
) -> LabourDetail:
    """Update contact information for the logged-in Labourer."""
    return update_self_labour_profile(db, account.id, data)


@router.get(
    "/{labour_id}",
    response_model=LabourDetail,
    dependencies=[Depends(require_roles(AccountRole.ADMIN))],
)
def get_labour_profile(labour_id: UUID, db: Session = Depends(get_db)) -> LabourDetail:
    """Get detailed profile of a specific labourer (Admin only)."""
    return get_labourer(db, labour_id)


@router.patch(
    "/{labour_id}",
    response_model=LabourDetail,
    dependencies=[Depends(require_roles(AccountRole.ADMIN))],
)
def update_labour_profile(
    labour_id: UUID, data: LabourUpdate, db: Session = Depends(get_db)
) -> LabourDetail:
    """Update labourer information or site assignment (Admin only)."""
    return update_labourer(db, labour_id, data)


@router.post(
    "/{labour_id}/assign-site",
    response_model=LabourDetail,
    dependencies=[Depends(require_roles(AccountRole.ADMIN))],
)
def assign_labourer_site(
    labour_id: UUID, data: LabourAssignSite, db: Session = Depends(get_db)
) -> LabourDetail:
    """Assign or reassign a labourer to a construction site (Admin only)."""
    return assign_site(db, labour_id, data.site_id)
