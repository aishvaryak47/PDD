from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from sqlalchemy.orm import selectinload
from typing import List
from uuid import UUID
from app.db.database import get_db
from app.models.models import Appointment, Client, Therapist, User
from app.schemas.schemas import AppointmentCreate, AppointmentResponse
from app.api.v1.auth import get_current_user

router = APIRouter(prefix="/appointments", tags=["Appointments"])

@router.post("", response_model=AppointmentResponse)
async def create_appointment(
    appt_in: AppointmentCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    if current_user.role != "client":
        raise HTTPException(status_code=403, detail="Only clients can book appointments.")

    client_res = await db.execute(select(Client).where(Client.user_id == current_user.id))
    client = client_res.scalars().first()
    if not client:
        raise HTTPException(status_code=404, detail="Client profile not found.")

    therapist_res = await db.execute(select(Therapist).where(Therapist.id == appt_in.therapist_id))
    therapist = therapist_res.scalars().first()
    if not therapist:
        raise HTTPException(status_code=404, detail="Therapist not found.")

    new_appt = Appointment(
        client_id=client.id,
        therapist_id=therapist.id,
        scheduled_at=appt_in.scheduled_at,
        duration_minutes=appt_in.duration_minutes,
        status="pending",
        price=therapist.hourly_rate,
        notes=appt_in.notes
    )
    db.add(new_appt)
    await db.commit()
    await db.refresh(new_appt)

    # Fetch loaded relationships
    res = await db.execute(
        select(Appointment)
        .where(Appointment.id == new_appt.id)
        .options(
            selectinload(Appointment.client).selectinload(Client.user),
            selectinload(Appointment.therapist).selectinload(Therapist.user)
        )
    )
    return res.scalars().first()

@router.get("/me", response_model=List[AppointmentResponse])
async def get_my_appointments(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    query = select(Appointment).options(
        selectinload(Appointment.client).selectinload(Client.user),
        selectinload(Appointment.therapist).selectinload(Therapist.user)
    )
    
    if current_user.role == "client":
        client_res = await db.execute(select(Client).where(Client.user_id == current_user.id))
        client = client_res.scalars().first()
        if not client:
            return []
        query = query.where(Appointment.client_id == client.id)
    else:
        therapist_res = await db.execute(select(Therapist).where(Therapist.user_id == current_user.id))
        therapist = therapist_res.scalars().first()
        if not therapist:
            return []
        query = query.where(Appointment.therapist_id == therapist.id)

    res = await db.execute(query.order_by(Appointment.scheduled_at.desc()))
    return res.scalars().all()

@router.patch("/{appointment_id}/status", response_model=AppointmentResponse)
async def update_appointment_status(
    appointment_id: UUID,
    status_str: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    res = await db.execute(
        select(Appointment)
        .where(Appointment.id == appointment_id)
        .options(
            selectinload(Appointment.client).selectinload(Client.user),
            selectinload(Appointment.therapist).selectinload(Therapist.user)
        )
    )
    appt = res.scalars().first()
    if not appt:
        raise HTTPException(status_code=404, detail="Appointment not found.")

    appt.status = status_str
    await db.commit()
    await db.refresh(appt)
    return appt
