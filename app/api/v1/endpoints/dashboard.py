"""Dashboards API endpoints."""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.models.account import Account, AccountRole
from app.schemas.dashboard import AdminDashboard, LabourDashboard, SupplierDashboard
from app.security.dependencies import require_roles
from app.services.dashboard_service import (
    get_admin_dashboard,
    get_labour_dashboard,
    get_supplier_dashboard,
)

router = APIRouter(prefix="/dashboard", tags=["dashboard"])


@router.get(
    "/admin",
    response_model=AdminDashboard,
    dependencies=[Depends(require_roles(AccountRole.ADMIN))],
)
def admin_dashboard(db: Session = Depends(get_db)) -> AdminDashboard:
    """Retrieve operational KPIs and stats for Admin Dashboard."""
    return get_admin_dashboard(db)


@router.get(
    "/labour",
    response_model=LabourDashboard,
)
def labour_dashboard(
    account: Account = Depends(require_roles(AccountRole.LABOUR)),
    db: Session = Depends(get_db),
) -> LabourDashboard:
    """Retrieve Labour profile, assigned site, and recent notifications."""
    return get_labour_dashboard(db, account.id)


@router.get(
    "/supplier",
    response_model=SupplierDashboard,
)
def supplier_dashboard(
    account: Account = Depends(require_roles(AccountRole.SUPPLIER)),
    db: Session = Depends(get_db),
) -> SupplierDashboard:
    """Retrieve Supplier profile, order requests counts, and recent notifications."""
    return get_supplier_dashboard(db, account.id)
