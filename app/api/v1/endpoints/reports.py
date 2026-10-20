"""Reports API endpoints."""

from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.models.account import AccountRole
from app.schemas.report import AdminReportsSummary
from app.security.dependencies import require_roles
from app.services.dashboard_service import get_admin_reports

router = APIRouter(prefix="/reports", tags=["reports"])


@router.get(
    "/summary",
    response_model=AdminReportsSummary,
    dependencies=[Depends(require_roles(AccountRole.ADMIN))],
)
def reports_summary(db: Session = Depends(get_db)) -> AdminReportsSummary:
    """Retrieve operational reports and aggregated stats (Admin only)."""
    return get_admin_reports(db)
