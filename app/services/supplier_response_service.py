"""Supplier Response (Quotation) service."""

from datetime import UTC, datetime
from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.models.account import Account, AccountRole
from app.models.material_request import MaterialRequestStatus
from app.models.supplier_response import ResponseStatus, SupplierResponse
from app.repositories.material_request_repository import get_material_request
from app.repositories.supplier_repository import get_supplier_by_account_id
from app.repositories.supplier_response_repository import (
    create_supplier_response,
    get_response_by_request_and_supplier,
    get_supplier_response,
    list_responses_by_supplier,
    list_responses_for_request,
)
from app.schemas.supplier_response import (
    SupplierResponseCreate,
    SupplierResponseDetail,
)
from app.services.notification_service import send_notification


def submit_quotation(
    db: Session,
    request_id: UUID,
    supplier_account_id: UUID,
    data: SupplierResponseCreate,
) -> SupplierResponseDetail:
    supplier = get_supplier_by_account_id(db, supplier_account_id)
    if supplier is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Supplier profile not found for this account",
        )

    mat_request = get_material_request(db, request_id)
    if mat_request is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Material request not found",
        )

    # Check if a response already exists from this supplier
    existing = get_response_by_request_and_supplier(db, request_id, supplier.id)
    if existing is not None:
        # Update existing submission
        existing.available_quantity = data.available_quantity
        existing.unit_price = data.unit_price
        existing.total_price = data.total_price
        existing.delivery_date = data.delivery_date
        existing.delivery_details = data.delivery_details
        existing.availability_status = data.availability_status.value
        existing.additional_notes = data.additional_notes
        existing.submission_date = datetime.now(UTC)
        existing.status = ResponseStatus.SUBMITTED.value
        resp = existing
    else:
        resp = SupplierResponse(
            request_id=request_id,
            supplier_id=supplier.id,
            available_quantity=data.available_quantity,
            unit_price=data.unit_price,
            total_price=data.total_price,
            delivery_date=data.delivery_date,
            delivery_details=data.delivery_details,
            availability_status=data.availability_status.value,
            additional_notes=data.additional_notes,
            status=ResponseStatus.SUBMITTED.value,
        )
        resp = create_supplier_response(db, resp)

    # Transition material request status to Responded if still Pending
    if mat_request.status == MaterialRequestStatus.PENDING.value:
        mat_request.status = MaterialRequestStatus.RESPONDED.value

    # Notify all Admins about new supplier response
    admins = list(
        db.scalars(
            select(Account).where(
                Account.role == AccountRole.ADMIN.value, Account.is_active.is_(True)
            )
        ).all()
    )
    for admin in admins:
        send_notification(
            db,
            recipient_id=admin.id,
            title="Supplier Quotation Submitted",
            message=(
                f"{supplier.company_name} submitted a quotation for {mat_request.material_name}."
            ),
            notification_type="SUPPLIER_RESPONSE_SUBMITTED",
            reference_id=resp.id,
        )

    db.commit()
    db.refresh(resp)
    return SupplierResponseDetail.model_validate(get_supplier_response(db, resp.id))


def get_quotation_by_id(db: Session, response_id: UUID) -> SupplierResponseDetail:
    resp = get_supplier_response(db, response_id)
    if resp is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Quotation response not found",
        )
    return SupplierResponseDetail.model_validate(resp)


def list_quotations_for_request(
    db: Session, request_id: UUID, *, status: str | None = None
) -> list[SupplierResponseDetail]:
    mat_request = get_material_request(db, request_id)
    if mat_request is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Material request not found",
        )
    responses = list_responses_for_request(db, request_id, status=status)
    return [SupplierResponseDetail.model_validate(r) for r in responses]


def list_own_quotations(
    db: Session,
    supplier_account_id: UUID,
    *,
    status: str | None = None,
    limit: int = 100,
    offset: int = 0,
) -> list[SupplierResponseDetail]:
    supplier = get_supplier_by_account_id(db, supplier_account_id)
    if supplier is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Supplier profile not found for this account",
        )
    responses = list_responses_by_supplier(
        db, supplier.id, status=status, limit=limit, offset=offset
    )
    return [SupplierResponseDetail.model_validate(r) for r in responses]


def review_quotation(
    db: Session,
    response_id: UUID,
    action: ResponseStatus,
    admin_notes: str | None = None,
) -> SupplierResponseDetail:
    resp = get_supplier_response(db, response_id)
    if resp is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Quotation response not found",
        )

    resp.status = action.value
    resp.reviewed_at = datetime.now(UTC)

    mat_request = get_material_request(db, resp.request_id)
    if action == ResponseStatus.ACCEPTED and mat_request:
        mat_request.status = MaterialRequestStatus.APPROVED.value

    # Notify the Supplier
    if resp.supplier and resp.supplier.account_id:
        status_text = "Accepted" if action == ResponseStatus.ACCEPTED else "Rejected"
        mat_name = mat_request.material_name if mat_request else "the request"
        send_notification(
            db,
            recipient_id=resp.supplier.account_id,
            title=f"Quotation {status_text}",
            message=f"Your quotation for {mat_name} has been {status_text.lower()}.",
            notification_type=f"QUOTATION_{action.value.upper()}",
            reference_id=resp.id,
        )

    db.commit()
    db.refresh(resp)
    return SupplierResponseDetail.model_validate(resp)
