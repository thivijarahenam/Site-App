"""Align schema with frontend models (logbook, marketplace, site details, labour attendance).

Revision ID: 0006_frontend_alignment
Revises: 0005_self_registration_and_otp
Create Date: 2026-10-27 10:30:00
"""

from collections.abc import Sequence

import sqlalchemy as sa
from alembic import op

revision: str = "0006_frontend_alignment"
down_revision: str | None = "0005_self_registration_and_otp"
branch_labels: str | Sequence[str] | None = None
depends_on: str | Sequence[str] | None = None


def upgrade() -> None:
    # 1. Add fields to construction_sites
    op.add_column(
        "construction_sites",
        sa.Column("progress", sa.Float(), server_default=sa.text("0.0"), nullable=False),
    )
    op.add_column(
        "construction_sites",
        sa.Column("contract_value", sa.String(length=100), nullable=True),
    )
    op.add_column(
        "construction_sites",
        sa.Column("cost_spent", sa.String(length=100), nullable=True),
    )
    op.add_column(
        "construction_sites",
        sa.Column("margin", sa.Float(), server_default=sa.text("0.0"), nullable=False),
    )
    op.add_column(
        "construction_sites",
        sa.Column("labour_count", sa.String(length=50), nullable=True),
    )
    op.add_column(
        "construction_sites",
        sa.Column("image_url", sa.String(length=500), nullable=True),
    )
    op.add_column(
        "construction_sites",
        sa.Column("supervisor_name", sa.String(length=200), nullable=True),
    )
    op.add_column(
        "construction_sites",
        sa.Column("supervisor_phone", sa.String(length=50), nullable=True),
    )
    op.add_column(
        "construction_sites",
        sa.Column("stages", sa.JSON(), nullable=True),
    )

    # 2. Add fields to labour_profiles
    op.add_column(
        "labour_profiles",
        sa.Column("daily_wage", sa.Float(), server_default=sa.text("3500.0"), nullable=False),
    )
    op.add_column(
        "labour_profiles",
        sa.Column("has_attended_today", sa.Boolean(), server_default=sa.text("true"), nullable=False),
    )

    # 3. Add assigned_supplier_id to material_requests
    op.add_column(
        "material_requests",
        sa.Column("assigned_supplier_id", sa.Uuid(), nullable=True),
    )
    op.create_foreign_key(
        "fk_material_requests_assigned_supplier_id",
        "material_requests",
        "supplier_profiles",
        ["assigned_supplier_id"],
        ["id"],
        ondelete="SET NULL",
    )
    op.create_index(
        "ix_material_requests_assigned_supplier_id",
        "material_requests",
        ["assigned_supplier_id"],
    )

    # 4. Create project_logbook_entries
    op.create_table(
        "project_logbook_entries",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("site_id", sa.Uuid(), nullable=False),
        sa.Column("entry_date", sa.DateTime(timezone=True), nullable=False),
        sa.Column("author_name", sa.String(length=200), nullable=False),
        sa.Column("author_role", sa.String(length=100), nullable=False),
        sa.Column("author_avatar", sa.String(length=500), nullable=True),
        sa.Column("category", sa.String(length=50), nullable=False),
        sa.Column("title", sa.String(length=255), nullable=False),
        sa.Column("description", sa.Text(), nullable=False),
        sa.Column("photo_urls", sa.JSON(), nullable=True),
        sa.Column("attachments", sa.JSON(), nullable=True),
        sa.Column("linked_items", sa.JSON(), nullable=True),
        sa.Column("is_acknowledged", sa.Boolean(), server_default=sa.text("false"), nullable=False),
        sa.Column("acknowledged_by", sa.String(length=200), nullable=True),
        sa.Column("acknowledged_at", sa.DateTime(timezone=True), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["site_id"], ["construction_sites.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "ix_project_logbook_entries_site_id",
        "project_logbook_entries",
        ["site_id"],
    )
    op.create_index(
        "ix_project_logbook_entries_category",
        "project_logbook_entries",
        ["category"],
    )

    # 5. Create logbook_comments
    op.create_table(
        "logbook_comments",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("entry_id", sa.Uuid(), nullable=False),
        sa.Column("author_name", sa.String(length=200), nullable=False),
        sa.Column("author_role", sa.String(length=100), nullable=False),
        sa.Column("text", sa.Text(), nullable=False),
        sa.Column("avatar_url", sa.String(length=500), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["entry_id"], ["project_logbook_entries.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index(
        "ix_logbook_comments_entry_id",
        "logbook_comments",
        ["entry_id"],
    )

    # 6. Create equipment_rentals
    op.create_table(
        "equipment_rentals",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("name", sa.String(length=200), nullable=False),
        sa.Column("category", sa.String(length=100), nullable=False),
        sa.Column("daily_rate", sa.Numeric(precision=12, scale=2), nullable=False),
        sa.Column("available_stock", sa.Integer(), server_default=sa.text("0"), nullable=False),
        sa.Column("on_rental_count", sa.Integer(), server_default=sa.text("0"), nullable=False),
        sa.Column("image_url", sa.String(length=500), nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_equipment_rentals_category", "equipment_rentals", ["category"])

    # 7. Create food_supply_orders
    op.create_table(
        "food_supply_orders",
        sa.Column("id", sa.Uuid(), nullable=False),
        sa.Column("site_id", sa.Uuid(), nullable=False),
        sa.Column("meal_type", sa.String(length=50), nullable=False),
        sa.Column("portions", sa.Integer(), nullable=False),
        sa.Column("delivery_date", sa.Date(), nullable=False),
        sa.Column("delivery_time", sa.String(length=50), nullable=False),
        sa.Column("status", sa.String(length=50), server_default=sa.text("'Pending'"), nullable=False),
        sa.Column("total_cost", sa.Numeric(precision=12, scale=2), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), nullable=False),
        sa.ForeignKeyConstraint(["site_id"], ["construction_sites.id"], ondelete="CASCADE"),
        sa.PrimaryKeyConstraint("id"),
    )
    op.create_index("ix_food_supply_orders_site_id", "food_supply_orders", ["site_id"])
    op.create_index("ix_food_supply_orders_status", "food_supply_orders", ["status"])


def downgrade() -> None:
    op.drop_table("food_supply_orders")
    op.drop_table("equipment_rentals")
    op.drop_table("logbook_comments")
    op.drop_table("project_logbook_entries")
    op.drop_index("ix_material_requests_assigned_supplier_id", "material_requests")
    op.drop_constraint("fk_material_requests_assigned_supplier_id", "material_requests", type_="foreignkey")
    op.drop_column("material_requests", "assigned_supplier_id")
    op.drop_column("labour_profiles", "has_attended_today")
    op.drop_column("labour_profiles", "daily_wage")
    op.drop_column("construction_sites", "stages")
    op.drop_column("construction_sites", "supervisor_phone")
    op.drop_column("construction_sites", "supervisor_name")
    op.drop_column("construction_sites", "image_url")
    op.drop_column("construction_sites", "labour_count")
    op.drop_column("construction_sites", "margin")
    op.drop_column("construction_sites", "cost_spent")
    op.drop_column("construction_sites", "contract_value")
    op.drop_column("construction_sites", "progress")
