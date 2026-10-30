"""Persistence operations for authentication accounts and refresh tokens."""

from datetime import datetime
from uuid import UUID

from sqlalchemy import select, update
from sqlalchemy.orm import Session

from app.models.account import Account, RefreshToken


def get_account_by_email(db: Session, email: str, *, for_update: bool = False) -> Account | None:
    statement = select(Account).where(Account.email == email)
    if for_update:
        statement = statement.with_for_update()
    return db.scalar(statement)


def get_account_by_identifier(
    db: Session, identifier: str, *, for_update: bool = False
) -> Account | None:
    """Find account by email or by phone number associated with labour or supplier profile."""
    clean_id = identifier.strip().lower()
    account = get_account_by_email(db, clean_id, for_update=for_update)
    if account is not None:
        return account

    # Search by phone number in LabourProfile or SupplierProfile
    from app.models.labour import LabourProfile
    from app.models.supplier import SupplierProfile

    clean_phone = "".join(c for c in clean_id if c.isdigit() or c == "+")
    phone_variants = {clean_id}
    if clean_phone:
        phone_variants.add(clean_phone)
        if clean_phone.startswith("0"):
            phone_variants.add("+94" + clean_phone[1:])
            phone_variants.add("94" + clean_phone[1:])
        elif clean_phone.startswith("+94"):
            phone_variants.add("0" + clean_phone[3:])
        elif clean_phone.startswith("94"):
            phone_variants.add("0" + clean_phone[2:])
            phone_variants.add("+" + clean_phone)

        labour = db.scalar(
            select(LabourProfile).where(LabourProfile.phone_number.in_(phone_variants))
        )
        if labour is not None:
            return get_account(db, labour.account_id)

        supplier = db.scalar(
            select(SupplierProfile).where(SupplierProfile.phone_number.in_(phone_variants))
        )
        if supplier is not None:
            return get_account(db, supplier.account_id)

    return None



def get_account(db: Session, account_id: UUID) -> Account | None:
    return db.get(Account, account_id)


def add_account(db: Session, account: Account) -> None:
    db.add(account)
    db.flush()


def add_refresh_token(db: Session, token: RefreshToken) -> None:
    db.add(token)


def get_refresh_token(
    db: Session, token_hash: str, *, for_update: bool = False
) -> RefreshToken | None:
    statement = select(RefreshToken).where(RefreshToken.token_hash == token_hash)
    if for_update:
        statement = statement.with_for_update()
    return db.scalar(statement)


def revoke_refresh_family(db: Session, family_id: UUID, at: datetime) -> None:
    db.execute(
        update(RefreshToken)
        .where(RefreshToken.family_id == family_id, RefreshToken.revoked_at.is_(None))
        .values(revoked_at=at)
    )


def revoke_account_refresh_tokens(db: Session, account_id: UUID, at: datetime) -> None:
    db.execute(
        update(RefreshToken)
        .where(RefreshToken.account_id == account_id, RefreshToken.revoked_at.is_(None))
        .values(revoked_at=at)
    )
