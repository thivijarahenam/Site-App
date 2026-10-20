"""Interactively reset an existing administrator password."""

from datetime import UTC, datetime
from getpass import getpass

from sqlalchemy import select

from app.database.session import SessionLocal
from app.models.account import Account, AccountRole
from app.repositories.account_repository import revoke_account_refresh_tokens
from app.security.password import hash_password


def main() -> None:
    """Reset a selected admin password without exposing it in shell history."""
    email = input("Admin email: ").strip().lower()
    password = getpass("New admin password (14+ characters): ")
    confirmation = getpass("Confirm new admin password: ")
    if password != confirmation:
        raise SystemExit("Passwords do not match")
    if len(password) < 14 or len(password) > 128:
        raise SystemExit("Admin password must be between 14 and 128 characters")

    with SessionLocal() as db:
        account = db.scalar(
            select(Account).where(
                Account.email == email,
                Account.role == AccountRole.ADMIN.value,
            )
        )
        if account is None:
            raise SystemExit("No admin account was found for that email")
        account.password_hash = hash_password(password)
        account.token_version += 1
        account.failed_login_attempts = 0
        account.locked_until = None
        revoke_account_refresh_tokens(db, account.id, datetime.now(UTC))
        db.commit()

    print("Admin password updated. Existing sessions have been invalidated.")


if __name__ == "__main__":
    main()
