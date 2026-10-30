"""Labour profile service."""

from uuid import UUID

from fastapi import HTTPException, status
from sqlalchemy.orm import Session

from app.models.account import Account, AccountRole
from app.models.labour import LabourProfile
from app.repositories.account_repository import add_account, get_account_by_email
from app.repositories.labour_repository import (
    create_labour_profile,
    get_labour_by_account_id,
    get_labour_by_id,
    get_labour_by_nic,
    list_labourers,
)
from app.repositories.site_repository import get_site
from app.schemas.labour import LabourCreate, LabourDetail, LabourSelfUpdate, LabourUpdate
from app.security.password import hash_password
from app.services.notification_service import send_notification


def create_labourer(db: Session, data: LabourCreate) -> LabourDetail:
    existing_account = get_account_by_email(db, data.email)
    if existing_account is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="An account with this email already exists",
        )
    existing_nic = get_labour_by_nic(db, data.nic_number)
    if existing_nic is not None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A labourer with this NIC / ID number already exists",
        )

    if data.current_site_id:
        site = get_site(db, data.current_site_id)
        if site is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Assigned construction site does not exist",
            )

    account = Account(
        email=data.email,
        password_hash=hash_password(data.password),
        role=AccountRole.LABOUR.value,
        is_active=True,
    )
    add_account(db, account)

    profile = LabourProfile(
        account_id=account.id,
        current_site_id=data.current_site_id,
        full_name=data.full_name,
        profile_photo=data.profile_photo,
        nic_number=data.nic_number,
        phone_number=data.phone_number,
        address=data.address,
        job_role=data.job_role,
        skills=data.skills,
        experience_years=data.experience_years,
        joining_date=data.joining_date,
        emergency_contact=data.emergency_contact,
        status=data.status.value,
        daily_wage=data.daily_wage,
        has_attended_today=data.has_attended_today,
    )
    profile = create_labour_profile(db, profile)

    if data.current_site_id:
        site = get_site(db, data.current_site_id)
        site_name = site.site_name if site else "Construction Site"
        send_notification(
            db,
            recipient_id=account.id,
            title="Site Assignment",
            message=f"You have been assigned to site: {site_name}.",
            notification_type="SITE_ASSIGNED",
            reference_id=data.current_site_id,
        )

    db.commit()
    return LabourDetail.model_validate(get_labour_by_id(db, profile.id))


def get_labourer(db: Session, labour_id: UUID) -> LabourDetail:
    profile = get_labour_by_id(db, labour_id)
    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Labourer profile not found",
        )
    return LabourDetail.model_validate(profile)


def get_labourer_by_account(db: Session, account_id: UUID) -> LabourDetail:
    profile = get_labour_by_account_id(db, account_id)
    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Labourer profile not found for this account",
        )
    return LabourDetail.model_validate(profile)


def update_labourer(db: Session, labour_id: UUID, data: LabourUpdate) -> LabourDetail:
    profile = get_labour_by_id(db, labour_id)
    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Labourer profile not found",
        )

    if data.nic_number is not None and data.nic_number != profile.nic_number:
        existing = get_labour_by_nic(db, data.nic_number)
        if existing and existing.id != profile.id:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="A labourer with this NIC already exists",
            )
        profile.nic_number = data.nic_number

    if data.current_site_id is not None and data.current_site_id != profile.current_site_id:
        site = get_site(db, data.current_site_id)
        if site is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Construction site not found",
            )
        profile.current_site_id = data.current_site_id
        send_notification(
            db,
            recipient_id=profile.account_id,
            title="Site Assignment Changed",
            message=f"Your assigned construction site was updated to {site.site_name}.",
            notification_type="SITE_CHANGED",
            reference_id=site.id,
        )

    if data.full_name is not None:
        profile.full_name = data.full_name
    if data.profile_photo is not None:
        profile.profile_photo = data.profile_photo
    if data.phone_number is not None:
        profile.phone_number = data.phone_number
    if data.address is not None:
        profile.address = data.address
    if data.job_role is not None:
        profile.job_role = data.job_role
    if data.skills is not None:
        profile.skills = data.skills
    if data.experience_years is not None:
        profile.experience_years = data.experience_years
    if data.joining_date is not None:
        profile.joining_date = data.joining_date
    if data.emergency_contact is not None:
        profile.emergency_contact = data.emergency_contact
    if data.status is not None:
        profile.status = data.status.value
    if data.daily_wage is not None:
        profile.daily_wage = data.daily_wage
    if data.has_attended_today is not None:
        profile.has_attended_today = data.has_attended_today

    db.commit()
    return LabourDetail.model_validate(get_labour_by_id(db, profile.id))


def toggle_labourer_attendance(db: Session, labour_id: UUID) -> LabourDetail:
    profile = get_labour_by_id(db, labour_id)
    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Labourer profile not found",
        )
    profile.has_attended_today = not profile.has_attended_today
    db.commit()
    return LabourDetail.model_validate(get_labour_by_id(db, profile.id))



def assign_site(db: Session, labour_id: UUID, site_id: UUID | None) -> LabourDetail:
    profile = get_labour_by_id(db, labour_id)
    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Labourer profile not found",
        )

    if site_id is not None:
        site = get_site(db, site_id)
        if site is None:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Construction site not found",
            )
        profile.current_site_id = site_id
        send_notification(
            db,
            recipient_id=profile.account_id,
            title="Site Assignment",
            message=f"You have been assigned to site: {site.site_name}.",
            notification_type="SITE_ASSIGNED",
            reference_id=site.id,
        )
    else:
        profile.current_site_id = None
        send_notification(
            db,
            recipient_id=profile.account_id,
            title="Site Unassigned",
            message="You have been unassigned from your previous construction site.",
            notification_type="SITE_UNASSIGNED",
        )

    db.commit()
    return LabourDetail.model_validate(get_labour_by_id(db, profile.id))


def update_self_labour_profile(
    db: Session, account_id: UUID, data: LabourSelfUpdate
) -> LabourDetail:
    profile = get_labour_by_account_id(db, account_id)
    if profile is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Labourer profile not found",
        )

    if data.phone_number is not None:
        profile.phone_number = data.phone_number
    if data.address is not None:
        profile.address = data.address
    if data.profile_photo is not None:
        profile.profile_photo = data.profile_photo
    if data.emergency_contact is not None:
        profile.emergency_contact = data.emergency_contact
    if data.job_role is not None:
        profile.job_role = data.job_role
    if data.skills is not None:
        profile.skills = data.skills
    if data.experience_years is not None:
        profile.experience_years = data.experience_years
    if data.daily_wage is not None:
        profile.daily_wage = data.daily_wage

    db.commit()
    return LabourDetail.model_validate(get_labour_by_id(db, profile.id))


def list_all_labourers(
    db: Session,
    *,
    site_id: UUID | None = None,
    status: str | None = None,
    job_role: str | None = None,
    search: str | None = None,
    limit: int = 100,
    offset: int = 0,
) -> list[LabourDetail]:
    labourers = list_labourers(
        db,
        site_id=site_id,
        status=status,
        job_role=job_role,
        search=search,
        limit=limit,
        offset=offset,
    )
    return [LabourDetail.model_validate(labourer) for labourer in labourers]
