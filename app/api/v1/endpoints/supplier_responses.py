"""Supplier Responses (Quotations) API endpoints."""

from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.models.account import Account, AccountRole
from app.schemas.supplier_response import (
    ReviewResponseAction,
    SupplierResponseCreate,
    SupplierResponseDetail,
)
from app.security.dependencies import require_roles
from app.services.supplier_response_service import (
    get_quotation_by_id,
    list_own_quotations,
    list_quotations_for_request,
    review_quotation,
    submit_quotation,
)

router = APIRouter(tags=["supplier-responses"])


@router.post(
    "/material-requests/{request_id}/responses",
    response_model=SupplierResponseDetail,
    status_code=status.HTTP_201_CREATED,
)
def submit_response(
    request_id: UUID,
    data: SupplierResponseCreate,
    account: Account = Depends(require_roles(AccountRole.SUPPLIER)),
    db: Session = Depends(get_db),
) -> SupplierResponseDetail:
    """Submit a material availability and pricing quotation (Supplier only)."""
    return submit_quotation(db, request_id, account.id, data)


@router.get(
    "/material-requests/{request_id}/responses",
    response_model=list[SupplierResponseDetail],
    dependencies=[Depends(require_roles(AccountRole.ADMIN))],
)
def get_responses_for_request(
    request_id: UUID,
    status: str | None = Query(
        None, description="Filter by status (Submitted, Accepted, Rejected)"
    ),
    db: Session = Depends(get_db),
) -> list[SupplierResponseDetail]:
    """View all supplier quotations submitted for a material request (Admin only)."""
    return list_quotations_for_request(db, request_id, status=status)


@router.get(
    "/supplier-responses/me",
    response_model=list[SupplierResponseDetail],
)
def get_own_responses(
    status: str | None = Query(
        None, description="Filter by status (Submitted, Accepted, Rejected)"
    ),
    limit: int = Query(100, ge=1, le=500),
    offset: int = Query(0, ge=0),
    account: Account = Depends(require_roles(AccountRole.SUPPLIER)),
    db: Session = Depends(get_db),
) -> list[SupplierResponseDetail]:
    """View history of quotations submitted by the logged-in Supplier."""
    return list_own_quotations(db, account.id, status=status, limit=limit, offset=offset)


@router.get(
    "/supplier-responses/{response_id}",
    response_model=SupplierResponseDetail,
)
def get_response(
    response_id: UUID,
    account: Account = Depends(require_roles(AccountRole.ADMIN, AccountRole.SUPPLIER)),
    db: Session = Depends(get_db),
) -> SupplierResponseDetail:
    """Get single quotation details (Admin or submitting Supplier)."""
    quotation = get_quotation_by_id(db, response_id)
    if account.role == AccountRole.SUPPLIER.value:
        if quotation.supplier and quotation.supplier.account_id != account.id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="You cannot view another supplier's quotation",
            )
    return quotation


@router.post(
    "/supplier-responses/{response_id}/review",
    response_model=SupplierResponseDetail,
    dependencies=[Depends(require_roles(AccountRole.ADMIN))],
)
def review_response(
    response_id: UUID,
    data: ReviewResponseAction,
    db: Session = Depends(get_db),
) -> SupplierResponseDetail:
    """Accept or reject a supplier quotation (Admin only)."""
    return review_quotation(db, response_id, data.action, data.admin_notes)
