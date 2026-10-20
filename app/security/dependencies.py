"""Reusable authentication and role-authorization dependencies."""

from collections.abc import Callable
from uuid import UUID

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy.orm import Session

from app.database.session import get_db
from app.models.account import Account, AccountRole
from app.security.tokens import decode_access_token, token_subject

bearer_scheme = HTTPBearer(auto_error=False)


def get_current_account(
    credentials: HTTPAuthorizationCredentials | None = Depends(bearer_scheme),
    db: Session = Depends(get_db),
) -> Account:
    """Resolve a valid bearer token to an active database account."""
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required",
            headers={"WWW-Authenticate": "Bearer"},
        )
    claims = decode_access_token(credentials.credentials)
    account_id: UUID = token_subject(claims)
    account = db.get(Account, account_id)
    if account is None or not account.is_active or claims.get("ver") != account.token_version:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired access token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return account


def require_roles(*roles: AccountRole) -> Callable[..., Account]:
    """Build a dependency restricting a route to selected account roles."""
    allowed = {role.value for role in roles}
    if AccountRole.LABOUR.value in allowed or AccountRole.EMPLOYEE.value in allowed:
        allowed.add(AccountRole.LABOUR.value)
        allowed.add(AccountRole.EMPLOYEE.value)

    def role_dependency(account: Account = Depends(get_current_account)) -> Account:
        if account.role not in allowed:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN, detail="Insufficient permissions"
            )
        return account

    return role_dependency
