"""Project logbook persistence models matching frontend ProjectLogbookEntry."""

from datetime import UTC, datetime
from enum import StrEnum
from typing import TYPE_CHECKING, Any
from uuid import UUID, uuid4

from sqlalchemy import Boolean, DateTime, ForeignKey, JSON, String, Text, Uuid
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.models.base import Base

if TYPE_CHECKING:
    from app.models.site import ConstructionSite


class LogbookCategory(StrEnum):
    """Categories for logbook entries, matching frontend LogbookCategory."""

    GENERAL_NOTE = "generalNote"
    DESIGN_CHANGE = "designChange"
    SITE_INSTRUCTION = "siteInstruction"
    SITE_OBSERVATION = "siteObservation"
    COST_VARIATION = "costVariation"
    CLIENT_REQUEST = "clientRequest"
    INSPECTION_QA = "inspectionQA"
    MEETING_NOTE = "meetingNote"
    OTHER = "other"


class ProjectLogbookEntry(Base):
    """Logbook entry for a construction site project."""

    __tablename__ = "project_logbook_entries"

    id: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    site_id: Mapped[UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("construction_sites.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    entry_date: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False
    )
    author_name: Mapped[str] = mapped_column(String(200), nullable=False)
    author_role: Mapped[str] = mapped_column(String(100), nullable=False)
    author_avatar: Mapped[str | None] = mapped_column(String(500), nullable=True)
    category: Mapped[str] = mapped_column(
        String(50), default=LogbookCategory.GENERAL_NOTE.value, nullable=False, index=True
    )
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    photo_urls: Mapped[list[str] | None] = mapped_column(JSON, nullable=True)
    attachments: Mapped[list[dict[str, Any]] | None] = mapped_column(JSON, nullable=True)
    linked_items: Mapped[list[str] | None] = mapped_column(JSON, nullable=True)
    is_acknowledged: Mapped[bool] = mapped_column(Boolean, default=False, nullable=False)
    acknowledged_by: Mapped[str | None] = mapped_column(String(200), nullable=True)
    acknowledged_at: Mapped[datetime | None] = mapped_column(DateTime(timezone=True), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False
    )

    # Relationships
    site: Mapped["ConstructionSite"] = relationship(
        "ConstructionSite", back_populates="logbook_entries"
    )
    comments: Mapped[list["LogbookComment"]] = relationship(
        "LogbookComment", back_populates="entry", cascade="all, delete-orphan", order_by="LogbookComment.created_at"
    )


class LogbookComment(Base):
    """Comment on a project logbook entry."""

    __tablename__ = "logbook_comments"

    id: Mapped[UUID] = mapped_column(Uuid(as_uuid=True), primary_key=True, default=uuid4)
    entry_id: Mapped[UUID] = mapped_column(
        Uuid(as_uuid=True),
        ForeignKey("project_logbook_entries.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    author_name: Mapped[str] = mapped_column(String(200), nullable=False)
    author_role: Mapped[str] = mapped_column(String(100), nullable=False)
    text: Mapped[str] = mapped_column(Text, nullable=False)
    avatar_url: Mapped[str | None] = mapped_column(String(500), nullable=True)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), default=lambda: datetime.now(UTC), nullable=False
    )

    # Relationships
    entry: Mapped[ProjectLogbookEntry] = relationship(
        ProjectLogbookEntry, back_populates="comments"
    )
