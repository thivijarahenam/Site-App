"""Supplier profile service."""

from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.account import Account, AccountRole
from app.models.supplier import SupplierProfile, SupplierStatus
from app.repositories.account_repository import add_account, get_account_by_email
from app.repositories.supplier_repository import (
    create_supplier_profile,
    get_supplier_by_account_id,
    get_supplier_by_id,
    list_suppliers,
)
from app.schemas.supplier import (
    SupplierCreate,
    SupplierDetail,
    SupplierSelfUpdate,
    SupplierUpdate,
)
from app.security.password import hash_password


def create_supplier(db: Session, data: SupplierCreate) -> SupplierDetail:
    existing = get_account_by_email(db, data.email)
    if existing is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="An account with this email already exists",
        )

    account = Account(
        email=data.email,
        password_hash=hash_password(data.password),
        role=AccountRole.SUPPLIER.value,
        is_active=True,
    )
    add_account(db, account)

    profile = SupplierProfile(
        account_id=account.id,
        company_name=data.company_name,
        contact_person=data.contact_person,
        phone_number=data.phone_number,
        email=data.email,
        address=data.address,
        company_registration_details=data.company_registration_details,
        materials_supplied=data.materials_supplied,
        bank_payment_info=data.bank_payment_info,
        company_status=data.company_status.value,
    )
    profile = create_supplier_profile(db, profile)
    db.commit()
    return SupplierDetail.model_validate(profile)


def get_supplier(db: Session, supplier_id: UUID) -> SupplierDetail:
    profile = get_supplier_by_id(db, supplier_id)
    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Supplier profile not found",
        )
    return SupplierDetail.model_validate(profile)


def get_supplier_by_account(db: Session, account_id: UUID) -> SupplierDetail:
    profile = get_supplier_by_account_id(db, account_id)
    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Supplier profile not found for this account",
        )
    return SupplierDetail.model_validate(profile)


def update_supplier(db: Session, supplier_id: UUID, data: SupplierUpdate) -> SupplierDetail:
    profile = get_supplier_by_id(db, supplier_id)
    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Supplier profile not found",
        )

    if data.company_name is not None:
        profile.company_name = data.company_name
    if data.contact_person is not None:
        profile.contact_person = data.contact_person
    if data.phone_number is not None:
        profile.phone_number = data.phone_number
    if data.email is not None:
        profile.email = data.email
    if data.address is not None:
        profile.address = data.address
    if data.company_registration_details is not None:
        profile.company_registration_details = data.company_registration_details
    if data.materials_supplied is not None:
        profile.materials_supplied = data.materials_supplied
    if data.bank_payment_info is not None:
        profile.bank_payment_info = data.bank_payment_info
    if data.company_status is not None:
        profile.company_status = data.company_status.value

    db.commit()
    db.refresh(profile)
    return SupplierDetail.model_validate(profile)


def update_self_supplier_profile(
    db: Session, account_id: UUID, data: SupplierSelfUpdate
) -> SupplierDetail:
    profile = get_supplier_by_account_id(db, account_id)
    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Supplier profile not found",
        )

    if data.contact_person is not None:
        profile.contact_person = data.contact_person
    if data.phone_number is not None:
        profile.phone_number = data.phone_number
    if data.address is not None:
        profile.address = data.address
    if data.materials_supplied is not None:
        profile.materials_supplied = data.materials_supplied
    if data.bank_payment_info is not None:
        profile.bank_payment_info = data.bank_payment_info

    db.commit()
    db.refresh(profile)
    return SupplierDetail.model_validate(profile)


def list_all_suppliers(
    db: Session,
    *,
    status: str | None = None,
    search: str | None = None,
    limit: int = 100,
    offset: int = 0,
) -> list[SupplierDetail]:
    suppliers = list_suppliers(db, status=status, search=search, limit=limit, offset=offset)
    return [SupplierDetail.model_validate(s) for s in suppliers]


def toggle_supplier_status(db: Session, supplier_id: UUID) -> SupplierDetail:
    profile = get_supplier_by_id(db, supplier_id)
    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Supplier profile not found",
        )
    if profile.company_status == SupplierStatus.ACTIVE.value:
        profile.company_status = SupplierStatus.INACTIVE.value
    else:
        profile.company_status = SupplierStatus.ACTIVE.value
    db.commit()
    db.refresh(profile)
    return SupplierDetail.model_validate(profile)
