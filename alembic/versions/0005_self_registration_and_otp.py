"""Add self registration, verification status, and account otps.

Revision ID: 0005_self_registration_and_otp
Revises: f9770bd6330b
Create Date: 2026-10-17 23:00:00
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0005_self_registration_and_otp"
down_revision: str | None = "f9770bd6330b"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    # 1. Update accounts table with verification columns
    op.add_column(
        "accounts",
        sa.Column("is_verified", sa.Boolean(), server_default=sa.text("true"), nullable=False),
    )
    op.add_column(
        "accounts",
        sa.Column(
            "verification_status",
            sa.String(length=20),
            server_default=sa.text("'VERIFIED'"),
            nullable=False,
        ),
    )
    op.create_index("ix_accounts_verification_status", "accounts", ["verification_status"])

    # 2. Create account_otps table
    op.create_table(
        "account_otps",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("account_id", sa.Uuid(), nullable=False),
        sa.Column("otp_hash", sa.String(length=64), nullable=False),
        sa.Column("purpose", sa.String(length=32), nullable=False),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("failed_attempts", sa.Integer(), server_default=sa.text("0"), nullable=False),
        sa.Column("consumed_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["account_id"], ["accounts.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_account_otps_account_id", "account_otps", ["account_id"])
    op.create_index("ix_account_otps_otp_hash", "account_otps", ["otp_hash"])
    op.create_index("ix_account_otps_purpose", "account_otps", ["purpose"])
    op.create_index("ix_account_otps_expires_at", "account_otps", ["expires_at"])

    # 3. Update labour_profiles with first_name, last_name, and make initial fields nullable
    op.add_column("labour_profiles", sa.Column("first_name", sa.String(length=100), nullable=True))
    op.add_column("labour_profiles", sa.Column("last_name", sa.String(length=100), nullable=True))
    op.alter_column("labour_profiles", "nic_number", nullable=True)
    op.alter_column("labour_profiles", "skills", nullable=True)
    op.alter_column("labour_profiles", "joining_date", nullable=True)
    op.alter_column("labour_profiles", "emergency_contact", nullable=True)

    # 4. Update supplier_profiles with first_name, last_name, and nullable optional details
    op.add_column(
        "supplier_profiles", sa.Column("first_name", sa.String(length=100), nullable=True)
    )
    op.add_column("supplier_profiles", sa.Column("last_name", sa.String(length=100), nullable=True))
    op.alter_column("supplier_profiles", "company_registration_details", nullable=True)
    op.alter_column("supplier_profiles", "materials_supplied", nullable=True)


def downgrade() -> None:
    op.alter_column("supplier_profiles", "materials_supplied", nullable=False)
    op.alter_column("supplier_profiles", "company_registration_details", nullable=False)
    op.drop_column("supplier_profiles", "last_name")
    op.drop_column("supplier_profiles", "first_name")

    op.alter_column("labour_profiles", "emergency_contact", nullable=False)
    op.alter_column("labour_profiles", "joining_date", nullable=False)
    op.alter_column("labour_profiles", "skills", nullable=False)
    op.alter_column("labour_profiles", "nic_number", nullable=False)
    op.drop_column("labour_profiles", "last_name")
    op.drop_column("labour_profiles", "first_name")

    op.drop_index("ix_account_otps_expires_at", table_name="account_otps")
    op.drop_index("ix_account_otps_purpose", table_name="account_otps")
    op.drop_index("ix_account_otps_otp_hash", table_name="account_otps")
    op.drop_index("ix_account_otps_account_id", table_name="account_otps")
    op.drop_table("account_otps")

    op.drop_index("ix_accounts_verification_status", table_name="accounts")
    op.drop_column("accounts", "verification_status")
    op.drop_column("accounts", "is_verified")
