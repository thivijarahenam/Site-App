"""Supplier Management API endpoints."""

from uuid import UUID

from fastapi import APIRouter, Depends, Query, status
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.models.account import Account, AccountRole
from app.schemas.supplier import (
    SupplierCreate,
    SupplierDetail,
    SupplierSelfUpdate,
    SupplierUpdate,
)
from app.security.dependencies import require_roles
from app.services.supplier_service import (
    create_supplier,
    get_supplier,
    get_supplier_by_account,
    list_all_suppliers,
    toggle_supplier_status,
    update_self_supplier_profile,
    update_supplier,
)

router = APIRouter(prefix="/suppliers", tags=["suppliers"])


@router.post(
    "",
    response_model=SupplierDetail,
    status_code=status.HTTP_201_CREATED,
    dependencies=[Depends(require_roles(AccountRole.ADMIN))],
)
def create_supplier_profile(data: SupplierCreate, db: Session = Depends(get_db)) -> SupplierDetail:
    """Register a new Supplier account and company profile (Admin only)."""
    return create_supplier(db, data)


@router.get(
    "",
    response_model=list[SupplierDetail],
    dependencies=[Depends(require_roles(AccountRole.ADMIN))],
)
def list_suppliers(
    status: str | None = Query(None, description="Filter by status (Active, Inactive)"),
    search: str | None = Query(
        None, description="Search company name, contact person, or materials"
    ),
    limit: int = Query(100, ge=1, le=500),
    offset: int = Query(0, ge=0),
    db: Session = Depends(get_db),
) -> list[SupplierDetail]:
    """List all registered suppliers (Admin only)."""
    return list_all_suppliers(db, status=status, search=search, limit=limit, offset=offset)


@router.get("/me", response_model=SupplierDetail)
def get_own_supplier_profile(
    account: Account = Depends(require_roles(AccountRole.SUPPLIER)),
    db: Session = Depends(get_db),
) -> SupplierDetail:
    """Get the company profile of the logged-in Supplier."""
    return get_supplier_by_account(db, account.id)


@router.patch("/me", response_model=SupplierDetail)
def update_own_supplier_profile(
    data: SupplierSelfUpdate,
    account: Account = Depends(require_roles(AccountRole.SUPPLIER)),
    db: Session = Depends(get_db),
) -> SupplierDetail:
    """Update profile details for the logged-in Supplier."""
    return update_self_supplier_profile(db, account.id, data)


@router.get(
    "/{supplier_id}",
    response_model=SupplierDetail,
    dependencies=[Depends(require_roles(AccountRole.ADMIN))],
)
def get_supplier_profile(supplier_id: UUID, db: Session = Depends(get_db)) -> SupplierDetail:
    """Get supplier details by ID (Admin only)."""
    return get_supplier(db, supplier_id)


@router.patch(
    "/{supplier_id}",
    response_model=SupplierDetail,
    dependencies=[Depends(require_roles(AccountRole.ADMIN))],
)
def update_supplier_profile(
    supplier_id: UUID, data: SupplierUpdate, db: Session = Depends(get_db)
) -> SupplierDetail:
    """Update supplier information (Admin only)."""
    return update_supplier(db, supplier_id, data)


@router.post(
    "/{supplier_id}/toggle-status",
    response_model=SupplierDetail,
    dependencies=[Depends(require_roles(AccountRole.ADMIN))],
)
def toggle_status(supplier_id: UUID, db: Session = Depends(get_db)) -> SupplierDetail:
    """Activate or deactivate a supplier (Admin only)."""
    return toggle_supplier_status(db, supplier_id)
