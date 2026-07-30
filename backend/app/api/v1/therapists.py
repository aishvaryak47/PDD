from fastapi import APIRouter, Depends, Query, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from typing import List, Optional
from uuid import UUID
from app.db.database import get_db
from app.models.models import Therapist, User
from app.schemas.schemas import TherapistResponse

router = APIRouter(prefix="/therapists", tags=["Therapists"])

@router.get("", response_model=List[TherapistResponse])
async def list_therapists(
    search: Optional[str] = None,
    min_rating: Optional[float] = None,
    max_rate: Optional[float] = None,
    db: AsyncSession = Depends(get_db)
):
    query = select(Therapist).options(selectinload(Therapist.user))
    
    if max_rate:
        query = query.where(Therapist.hourly_rate <= max_rate)
    if min_rating:
        query = query.where(Therapist.rating_avg >= min_rating)
        
    result = await db.execute(query)
    therapists = result.scalars().all()

    if search:
        search_lower = search.lower()
        therapists = [
            t for t in therapists 
            if search_lower in t.user.full_name.lower() or search_lower in (t.title or "").lower() or search_lower in (t.biography or "").lower()
        ]

    return therapists

@router.get("/nearby", response_model=List[TherapistResponse])
async def get_nearby_therapists(
    lat: float = Query(..., description="Latitude"),
    lng: float = Query(..., description="Longitude"),
    radius_km: float = Query(50.0, description="Radius in KM"),
    db: AsyncSession = Depends(get_db)
):
    # Simple Euclidean distance filtering for nearby demo
    result = await db.execute(select(Therapist).options(selectinload(Therapist.user)))
    therapists = result.scalars().all()
    
    nearby = []
    for t in therapists:
        if t.latitude is not None and t.longitude is not None:
            # Approx distance calculation
            d_lat = t.latitude - lat
            d_lng = t.longitude - lng
            dist_approx = (d_lat**2 + d_lng**2)**0.5 * 111.0 # 1 degree ~ 111 km
            if dist_approx <= radius_km:
                nearby.append(t)
                
    return nearby

@router.get("/{therapist_id}", response_model=TherapistResponse)
async def get_therapist_detail(therapist_id: UUID, db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(Therapist).where(Therapist.id == therapist_id).options(selectinload(Therapist.user))
    )
    therapist = result.scalars().first()
    if not therapist:
        raise HTTPException(status_code=404, detail="Therapist not found.")
    return therapist
