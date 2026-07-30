from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from app.db.database import get_db
from app.models.models import MoodLog, Client, User
from app.schemas.schemas import MoodLogCreate, MoodLogResponse
from app.api.v1.auth import get_current_user
from app.services.groq_service import groq_service

router = APIRouter(prefix="/mood", tags=["Mood Analyzer"])

@router.post("", response_model=MoodLogResponse)
async def create_mood_log(
    mood_in: MoodLogCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    if current_user.role != "client":
        raise HTTPException(status_code=403, detail="Only clients can log mood.")

    client_res = await db.execute(select(Client).where(Client.user_id == current_user.id))
    client = client_res.scalars().first()
    if not client:
        raise HTTPException(status_code=404, detail="Client profile not found.")

    new_log = MoodLog(
        client_id=client.id,
        mood_score=mood_in.mood_score,
        emotion_tags=mood_in.emotion_tags,
        note=mood_in.note
    )
    db.add(new_log)
    await db.commit()
    await db.refresh(new_log)
    return new_log

@router.get("/me", response_model=List[MoodLogResponse])
async def get_my_mood_logs(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    client_res = await db.execute(select(Client).where(Client.user_id == current_user.id))
    client = client_res.scalars().first()
    if not client:
        return []

    res = await db.execute(select(MoodLog).where(MoodLog.client_id == client.id).order_by(MoodLog.logged_at.desc()))
    return res.scalars().all()

@router.get("/insights")
async def get_mood_insights(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    client_res = await db.execute(select(Client).where(Client.user_id == current_user.id))
    client = client_res.scalars().first()
    if not client:
        return {"insight": "No data available."}

    res = await db.execute(select(MoodLog).where(MoodLog.client_id == client.id).order_by(MoodLog.logged_at.desc()))
    logs = res.scalars().all()
    scores = [l.mood_score for l in logs[:14]]
    
    insight_text = await groq_service.analyze_mood_trends(scores)
    return {
        "insight": insight_text,
        "recent_average": sum(scores)/len(scores) if scores else 4.0,
        "total_entries": len(logs)
    }
