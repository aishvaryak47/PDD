from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from app.db.database import get_db
from app.models.models import Journal, Client, User
from app.schemas.schemas import JournalCreate, JournalResponse
from app.api.v1.auth import get_current_user
from app.services.groq_service import groq_service

router = APIRouter(prefix="/journals", tags=["Journals"])

@router.post("", response_model=JournalResponse)
async def create_journal_entry(
    journal_in: JournalCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    if current_user.role != "client":
        raise HTTPException(status_code=403, detail="Only clients can write journals.")

    client_res = await db.execute(select(Client).where(Client.user_id == current_user.id))
    client = client_res.scalars().first()
    if not client:
        raise HTTPException(status_code=404, detail="Client profile not found.")

    # Generate AI summary automatically
    ai_summary = await groq_service.summarize_journal(journal_in.title, journal_in.content)

    new_journal = Journal(
        client_id=client.id,
        title=journal_in.title,
        content=journal_in.content,
        audio_url=journal_in.audio_url,
        ai_summary=ai_summary
    )
    db.add(new_journal)
    await db.commit()
    await db.refresh(new_journal)
    return new_journal

@router.get("/me", response_model=List[JournalResponse])
async def get_my_journals(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    client_res = await db.execute(select(Client).where(Client.user_id == current_user.id))
    client = client_res.scalars().first()
    if not client:
        return []

    res = await db.execute(select(Journal).where(Journal.client_id == client.id).order_by(Journal.created_at.desc()))
    return res.scalars().all()
