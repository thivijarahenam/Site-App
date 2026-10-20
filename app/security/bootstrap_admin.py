"""Interactive one-time bootstrap for the first administrator account."""

from getpass import getpass

from sqlalchemy import select

from app.database.session import SessionLocal
from app.models.account import Account, AccountRole
from app.services.auth_service import create_initial_admin


def main() -> None:
    """Prompt securely and create an initial admin in the configured database."""
    email = input("Admin email: ").strip().lower()
    password = getpass("Admin password (14+ characters): ")
    confirmation = getpass("Confirm admin password: ")
    if password != confirmation:
        raise SystemExit("Passwords do not match")
    with SessionLocal() as db:
        existing = db.scalar(
            select(Account.id).where(Account.role == AccountRole.ADMIN.value).limit(1)
        )
        if existing is not None:
            raise SystemExit("An admin account already exists")
        try:
            account = create_initial_admin(db, email, password)
        except ValueError as exc:
            raise SystemExit(str(exc)) from exc
    print(f"Created initial admin account {account.email} ({account.id}).")


if __name__ == "__main__":
    main()
