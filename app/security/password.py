"""Argon2id password hashing utilities."""

from pwdlib import PasswordHash

password_hash = PasswordHash.recommended()
_dummy_hash = password_hash.hash("dummy-password-used-for-timing-equalization")


def hash_password(password: str) -> str:
    """Hash a plaintext password with the recommended Argon2id configuration."""
    return password_hash.hash(password)


def verify_password(password: str, encoded_hash: str) -> bool:
    """Safely verify a password against its stored encoded hash."""
    try:
        return password_hash.verify(password, encoded_hash)
    except (ValueError, TypeError):
        return False


def verify_dummy_password(password: str) -> None:
    """Spend comparable hash work when the submitted account does not exist."""
    verify_password(password, _dummy_hash)
