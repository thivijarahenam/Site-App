"""Environment-based application settings."""

from functools import lru_cache

from pydantic import Field, SecretStr, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Validated configuration loaded from environment and .env."""

    model_config = SettingsConfigDict(
        env_file=".env", env_file_encoding="utf-8", case_sensitive=False, extra="ignore"
    )

    app_name: str = "Flutter Backend API"
    environment: str = "development"
    log_level: str = "INFO"
    database_url: SecretStr = Field(
        default=SecretStr("postgresql+psycopg://app:change-me@localhost:5432/app")
    )
    jwt_secret_key: SecretStr | None = Field(default=None, min_length=32)
    access_token_minutes: int = Field(default=15, ge=5, le=60)
    refresh_token_days: int = Field(default=30, ge=1, le=90)
    jwt_issuer: str = "flutter-backend"
    jwt_audience: str = "flutter-client"
    cors_origins: list[str] = Field(default_factory=list)
    docs_enabled: bool = True
    account_link_token_secret: SecretStr | None = Field(default=None, min_length=32)
    password_reset_link_minutes: int = Field(default=15, ge=5, le=60)
    account_invitation_link_hours: int = Field(default=24, ge=1, le=72)
    account_action_resend_seconds: int = Field(default=60, ge=30, le=600)
    mailtrap_host: str = "sandbox.smtp.mailtrap.io"
    mailtrap_port: int = Field(default=2525, ge=1, le=65535)
    mailtrap_username: str = ""
    mailtrap_password: SecretStr | None = None
    mail_from: str = "no-reply@example.com"
    mail_from_name: str = "Flutter Backend API"
    app_link_base_url: str = "https://app.example.com"

    @field_validator("environment")
    @classmethod
    def normalize_environment(cls, value: str) -> str:
        return value.strip().lower()

    @field_validator("jwt_secret_key", mode="before")
    @classmethod
    def empty_jwt_secret_is_unset(cls, value: object) -> object:
        return None if value == "" else value

    @field_validator("account_link_token_secret", mode="before")
    @classmethod
    def empty_account_link_secret_is_unset(cls, value: object) -> object:
        return None if value == "" else value

    @field_validator("mailtrap_password", mode="before")
    @classmethod
    def empty_mail_password_is_unset(cls, value: object) -> object:
        return None if value == "" else value


@lru_cache
def get_settings() -> Settings:
    """Return cached application settings."""
    return Settings()


settings = get_settings()
