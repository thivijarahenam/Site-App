"""Create civil construction site management schema.

Revision ID: f9770bd6330b
Revises: 0003_account_action_links
Create Date: 2026-10-17 00:13:22
"""

from collections.abc import Sequence

import sqlalchemy as sa

from alembic import op

revision: str = "f9770bd6330b"
down_revision: str | None = "0003_account_action_links"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    # 1. Construction Sites
    op.create_table(
        "construction_sites",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("site_name", sa.String(length=200), nullable=False),
        sa.Column("project_name", sa.String(length=200), nullable=False),
        sa.Column("site_address", sa.String(length=500), nullable=False),
        sa.Column("client_name", sa.String(length=200), nullable=False),
        sa.Column("start_date", sa.Date(), nullable=False),
        sa.Column("expected_completion_date", sa.Date(), nullable=False),
        sa.Column("status", sa.String(length=20), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_construction_sites_site_name", "construction_sites", ["site_name"])
    op.create_index("ix_construction_sites_project_name", "construction_sites", ["project_name"])
    op.create_index("ix_construction_sites_status", "construction_sites", ["status"])

    # 2. Labour Profiles
    op.create_table(
        "labour_profiles",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("account_id", sa.Uuid(), nullable=False),
        sa.Column("current_site_id", sa.Uuid(), nullable=True),
        sa.Column("full_name", sa.String(length=200), nullable=False),
        sa.Column("profile_photo", sa.String(length=500), nullable=True),
        sa.Column("nic_number", sa.String(length=50), nullable=False),
        sa.Column("phone_number", sa.String(length=30), nullable=False),
        sa.Column("address", sa.String(length=500), nullable=False),
        sa.Column("job_role", sa.String(length=100), nullable=False),
        sa.Column("skills", sa.Text(), nullable=False),
        sa.Column("experience_years", sa.Integer(), nullable=False),
        sa.Column("joining_date", sa.Date(), nullable=False),
        sa.Column("emergency_contact", sa.String(length=200), nullable=False),
        sa.Column("status", sa.String(length=20), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["account_id"], ["accounts.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(
            ["current_site_id"], ["construction_sites.id"], ondelete="SET NULL"
        ),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("account_id"),
        sa.UniqueConstraint("nic_number"),
    )
    op.create_index("ix_labour_profiles_account_id", "labour_profiles", ["account_id"])
    op.create_index("ix_labour_profiles_current_site_id", "labour_profiles", ["current_site_id"])
    op.create_index("ix_labour_profiles_full_name", "labour_profiles", ["full_name"])
    op.create_index("ix_labour_profiles_job_role", "labour_profiles", ["job_role"])
    op.create_index("ix_labour_profiles_nic_number", "labour_profiles", ["nic_number"])
    op.create_index("ix_labour_profiles_status", "labour_profiles", ["status"])

    # 3. Supplier Profiles
    op.create_table(
        "supplier_profiles",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("account_id", sa.Uuid(), nullable=False),
        sa.Column("company_name", sa.String(length=200), nullable=False),
        sa.Column("contact_person", sa.String(length=200), nullable=False),
        sa.Column("phone_number", sa.String(length=30), nullable=False),
        sa.Column("email", sa.String(length=254), nullable=False),
        sa.Column("address", sa.String(length=500), nullable=False),
        sa.Column("company_registration_details", sa.String(length=200), nullable=False),
        sa.Column("materials_supplied", sa.Text(), nullable=False),
        sa.Column("bank_payment_info", sa.Text(), nullable=True),
        sa.Column("company_status", sa.String(length=20), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["account_id"], ["accounts.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
        sa.UniqueConstraint("account_id"),
    )
    op.create_index("ix_supplier_profiles_account_id", "supplier_profiles", ["account_id"])
    op.create_index("ix_supplier_profiles_company_name", "supplier_profiles", ["company_name"])
    op.create_index("ix_supplier_profiles_company_status", "supplier_profiles", ["company_status"])

    # 4. Material Requests
    op.create_table(
        "material_requests",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("site_id", sa.Uuid(), nullable=False),
        sa.Column("material_name", sa.String(length=200), nullable=False),
        sa.Column("material_category", sa.String(length=100), nullable=False),
        sa.Column("required_quantity", sa.Numeric(precision=12, scale=2), nullable=False),
        sa.Column("unit", sa.String(length=50), nullable=False),
        sa.Column("required_date", sa.Date(), nullable=False),
        sa.Column("description", sa.Text(), nullable=True),
        sa.Column("additional_notes", sa.Text(), nullable=True),
        sa.Column("request_date", sa.Date(), nullable=False),
        sa.Column("status", sa.String(length=20), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("updated_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["site_id"], ["construction_sites.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_material_requests_site_id", "material_requests", ["site_id"])
    op.create_index("ix_material_requests_material_name", "material_requests", ["material_name"])
    op.create_index(
        "ix_material_requests_material_category", "material_requests", ["material_category"]
    )
    op.create_index("ix_material_requests_status", "material_requests", ["status"])

    # 5. Supplier Responses (Quotations)
    op.create_table(
        "supplier_responses",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("request_id", sa.Uuid(), nullable=False),
        sa.Column("supplier_id", sa.Uuid(), nullable=False),
        sa.Column("available_quantity", sa.Numeric(precision=12, scale=2), nullable=False),
        sa.Column("unit_price", sa.Numeric(precision=12, scale=2), nullable=False),
        sa.Column("total_price", sa.Numeric(precision=14, scale=2), nullable=False),
        sa.Column("delivery_date", sa.Date(), nullable=False),
        sa.Column("delivery_details", sa.Text(), nullable=True),
        sa.Column("availability_status", sa.String(length=20), nullable=False),
        sa.Column("additional_notes", sa.Text(), nullable=True),
        sa.Column("submission_date", sa.DateTime(timezone=True), nullable=False),
        sa.Column("status", sa.String(length=20), nullable=False),
        sa.Column("reviewed_at", sa.DateTime(timezone=True), nullable=True),
        sa.ForeignKeyConstraint(["request_id"], ["material_requests.id"], ondelete="CASCADE"),
        sa.ForeignKeyConstraint(["supplier_id"], ["supplier_profiles.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_supplier_responses_request_id", "supplier_responses", ["request_id"])
    op.create_index("ix_supplier_responses_supplier_id", "supplier_responses", ["supplier_id"])
    op.create_index("ix_supplier_responses_status", "supplier_responses", ["status"])

    # 6. Notifications
    op.create_table(
        "notifications",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("recipient_id", sa.Uuid(), nullable=False),
        sa.Column("title", sa.String(length=200), nullable=False),
        sa.Column("message", sa.Text(), nullable=False),
        sa.Column("notification_type", sa.String(length=50), nullable=False),
        sa.Column("reference_id", sa.Uuid(), nullable=True),
        sa.Column("is_read", sa.Boolean(), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["recipient_id"], ["accounts.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_notifications_recipient_id", "notifications", ["recipient_id"])
    op.create_index("ix_notifications_notification_type", "notifications", ["notification_type"])
    op.create_index("ix_notifications_is_read", "notifications", ["is_read"])


def downgrade() -> None:
    op.drop_index("ix_notifications_is_read", table_name="notifications")
    op.drop_index("ix_notifications_notification_type", table_name="notifications")
    op.drop_index("ix_notifications_recipient_id", table_name="notifications")
    op.drop_table("notifications")

    op.drop_index("ix_supplier_responses_status", table_name="supplier_responses")
    op.drop_index("ix_supplier_responses_supplier_id", table_name="supplier_responses")
    op.drop_index("ix_supplier_responses_request_id", table_name="supplier_responses")
    op.drop_table("supplier_responses")

    op.drop_index("ix_material_requests_status", table_name="material_requests")
    op.drop_index("ix_material_requests_material_category", table_name="material_requests")
    op.drop_index("ix_material_requests_material_name", table_name="material_requests")
    op.drop_index("ix_material_requests_site_id", table_name="material_requests")
    op.drop_table("material_requests")

    op.drop_index("ix_supplier_profiles_company_status", table_name="supplier_profiles")
    op.drop_index("ix_supplier_profiles_company_name", table_name="supplier_profiles")
    op.drop_index("ix_supplier_profiles_account_id", table_name="supplier_profiles")
    op.drop_table("supplier_profiles")

    op.drop_index("ix_labour_profiles_status", table_name="labour_profiles")
    op.drop_index("ix_labour_profiles_nic_number", table_name="labour_profiles")
    op.drop_index("ix_labour_profiles_job_role", table_name="labour_profiles")
    op.drop_index("ix_labour_profiles_full_name", table_name="labour_profiles")
    op.drop_index("ix_labour_profiles_current_site_id", table_name="labour_profiles")
    op.drop_index("ix_labour_profiles_account_id", table_name="labour_profiles")
    op.drop_table("labour_profiles")

    op.drop_index("ix_construction_sites_status", table_name="construction_sites")
    op.drop_index("ix_construction_sites_project_name", table_name="construction_sites")
    op.drop_index("ix_construction_sites_site_name", table_name="construction_sites")
    op.drop_table("construction_sites")
