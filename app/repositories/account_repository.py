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
