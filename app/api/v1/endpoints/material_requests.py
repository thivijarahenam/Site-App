"""Material Requests API endpoints."""

from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.models.account import AccountRole
from app.schemas.material_request import (
    MaterialRequestCreate,
    MaterialRequestDetail,
    MaterialRequestUpdate,
)
from app.security.dependencies import require_roles
from app.services.material_request_service import (
    create_request,
    get_request_by_id,
    list_requests,
    remove_request,
    update_request,
)

router = APIRouter(prefix="/material-requests", tags=["material-requests"])


@router.post(
    "",
    response_model=MaterialRequestDetail,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(require_roles(AccountRole.ADMIN))],
)
def create_material_request(
    data: MaterialRequestCreate, db: Session = Depends(get_db)
) -> MaterialRequestDetail:
    """Create a new material request for a site (Admin only)."""
    return create_request(db, data)


@router.get(
    "",
    response_model=list[MaterialRequestDetail],
    dependencies=[Depends(require_roles(AccountRole.ADMIN, AccountRole.SUPPLIER))],
)
def list_material_requests(
    site_id: UUID | None = Query(None, description="Filter by site ID"),
    status: str | None = Query(
        None, description="Filter by status (Pending, Responded, Approved, Completed, Cancelled)"
    ),
    material_category: str | None = Query(None, description="Filter by category"),
    search: str | None = Query(None, description="Search material name or description"),
    limit: int = Query(100, ge=1, le=500),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
) -> list[MaterialRequestDetail]:
    """List material requests (Admin and Supplier)."""
    return list_requests(
        db,
        site_id=site_id,
        status=status,
        material_category=material_category,
        search=search,
        limit=limit,
        offset=offset,
    )


@router.get(
    "/{request_id}",
    response_model=MaterialRequestDetail,
    dependencies=[Depends(require_roles(AccountRole.ADMIN, AccountRole.SUPPLIER))],
)
def get_material_request(request_id: UUID, db: Session = Depends(get_db)) -> MaterialRequestDetail:
    """Get details of a material request (Admin and Supplier)."""
    return get_request_by_id(db, request_id)


@router.patch(
    "/{request_id}",
    response_model=MaterialRequestDetail,
    dependencies=[Depends(require_roles(AccountRole.ADMIN))],
)
def update_material_request(
    request_id: UUID, data: MaterialRequestUpdate, db: Session = Depends(get_db)
) -> MaterialRequestDetail:
    """Update material request specifications or status (Admin only)."""
    return update_request(db, request_id, data)


@router.delete(
    "/{request_id}",
    status_code=status.HTTP_204_NO_CONTENT,
    dependencies=[Depends(require_roles(AccountRole.ADMIN))],
)
def delete_material_request(request_id: UUID, db: Session = Depends(get_db)) -> None:
    """Delete a material request (Admin only)."""
    remove_request(db, request_id)
