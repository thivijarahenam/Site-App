"""Material request service."""

from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.material_request import MaterialRequest
from app.models.supplier import SupplierStatus
from app.repositories.material_request_repository import (
    create_material_request,
    delete_material_request,
    get_material_request,
    get_request_response_count,
    list_material_requests,
)
from app.repositories.site_repository import get_site
from app.repositories.supplier_repository import list_suppliers
from app.schemas.material_request import (
    MaterialRequestCreate,
    MaterialRequestDetail,
    MaterialRequestUpdate,
)
from app.schemas.site import SitePublic
from app.services.notification_service import send_notification


def _to_request_detail(req: MaterialRequest, resp_count: int) -> MaterialRequestDetail:
    from app.schemas.supplier import SupplierDetail

    return MaterialRequestDetail(
        id=req.id,
        site_id=req.site_id,
        material_name=req.material_name,
        material_category=req.material_category,
        required_quantity=req.required_quantity,
        unit=req.unit,
        required_date=req.required_date,
        description=req.description,
        additional_notes=req.additional_notes,
        request_date=req.request_date,
        status=req.status,
        assigned_supplier_id=req.assigned_supplier_id,
        assigned_supplier=SupplierDetail.model_validate(req.assigned_supplier) if getattr(req, "assigned_supplier", None) else None,
        created_at=req.created_at,
        updated_at=req.updated_at,
        site=SitePublic.model_validate(req.site) if req.site else None,
        response_count=resp_count,
    )


def create_request(db: Session, data: MaterialRequestCreate) -> MaterialRequestDetail:
    site = get_site(db, data.site_id)
    if site is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Construction site not found",
        )

    req = MaterialRequest(
        site_id=data.site_id,
        assigned_supplier_id=data.assigned_supplier_id,
        material_name=data.material_name,
        material_category=data.material_category,
        required_quantity=data.required_quantity,
        unit=data.unit,
        required_date=data.required_date,
        description=data.description,
        additional_notes=data.additional_notes,
    )
    req = create_material_request(db, req)

    # Notify active suppliers about the new material request
    active_suppliers = list_suppliers(db, status=SupplierStatus.ACTIVE.value)
    for supplier in active_suppliers:
        send_notification(
            db,
            recipient_id=supplier.account_id,
            title="New Material Request",
            message=(
                f"New request for {req.material_name} "
                f"({req.required_quantity} {req.unit}) at {site.site_name}."
            ),
            notification_type="NEW_MATERIAL_REQUEST",
            reference_id=req.id,
        )

    db.commit()
    db.refresh(req)
    return _to_request_detail(req, 0)


def get_request_by_id(db: Session, request_id: UUID) -> MaterialRequestDetail:
    req = get_material_request(db, request_id)
    if req is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Material request not found",
        )
    resp_count = get_request_response_count(db, req.id)
    return _to_request_detail(req, resp_count)


def update_request(
    db: Session, request_id: UUID, data: MaterialRequestUpdate
) -> MaterialRequestDetail:
    req = get_material_request(db, request_id)
    if req is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Material request not found",
        )

    if data.material_name is not None:
        req.material_name = data.material_name
    if data.material_category is not None:
        req.material_category = data.material_category
    if data.required_quantity is not None:
        req.required_quantity = data.required_quantity
    if data.unit is not None:
        req.unit = data.unit
    if data.required_date is not None:
        req.required_date = data.required_date
    if data.description is not None:
        req.description = data.description
    if data.additional_notes is not None:
        req.additional_notes = data.additional_notes
    if data.status is not None:
        req.status = data.status.value
    if data.assigned_supplier_id is not None:
        req.assigned_supplier_id = data.assigned_supplier_id

    db.commit()
    db.refresh(req)
    resp_count = get_request_response_count(db, req.id)
    return _to_request_detail(req, resp_count)


def list_requests(
    db: Session,
    *,
    site_id: UUID | None = None,
    status: str | None = None,
    material_category: str | None = None,
    search: str | None = None,
    limit: int = 100,
    offset: int = 0,
) -> list[MaterialRequestDetail]:
    requests = list_material_requests(
        db,
        site_id=site_id,
        status=status,
        material_category=material_category,
        search=search,
        limit=limit,
        offset=offset,
    )
    return [_to_request_detail(r, get_request_response_count(db, r.id)) for r in requests]


def remove_request(db: Session, request_id: UUID) -> None:
    req = get_material_request(db, request_id)
    if req is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Material request not found",
        )
    delete_material_request(db, req)
    db.commit()
