from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from app.db.database import get_db
from app.models.models import User, Client, Therapist
from app.schemas.schemas import UserCreate, LoginRequest, RefreshTokenRequest, Token, UserResponse, ClientProfileCreate, TherapistProfileCreate
from app.core.security import verify_password, get_password_hash, create_access_token, create_refresh_token, decode_token, oauth2_scheme

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/register/client", response_model=Token)
async def register_client(user_in: UserCreate, profile_in: ClientProfileCreate, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == user_in.email))
    if result.scalars().first():
        raise HTTPException(status_code=400, detail="User with this email already exists.")

    new_user = User(
        email=user_in.email,
        password_hash=get_password_hash(user_in.password),
        full_name=user_in.full_name,
        role="client"
    )
    db.add(new_user)
    await db.flush()

    new_client = Client(
        user_id=new_user.id,
        phone=profile_in.phone,
        date_of_birth=profile_in.date_of_birth,
        emergency_contact_name=profile_in.emergency_contact_name,
        emergency_contact_phone=profile_in.emergency_contact_phone,
        therapy_preferences=profile_in.therapy_preferences
    )
    db.add(new_client)
    await db.commit()
    await db.refresh(new_user)

    access_token = create_access_token(subject=str(new_user.id), role=new_user.role)
    refresh_token = create_refresh_token(subject=str(new_user.id))
    return Token(access_token=access_token, refresh_token=refresh_token, user=UserResponse.model_validate(new_user))

@router.post("/register/therapist", response_model=Token)
async def register_therapist(user_in: UserCreate, profile_in: TherapistProfileCreate, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == user_in.email))
    if result.scalars().first():
        raise HTTPException(status_code=400, detail="User with this email already exists.")

    new_user = User(
        email=user_in.email,
        password_hash=get_password_hash(user_in.password),
        full_name=user_in.full_name,
        role="therapist"
    )
    db.add(new_user)
    await db.flush()

    new_therapist = Therapist(
        user_id=new_user.id,
        title=profile_in.title,
        biography=profile_in.biography,
        location_address=profile_in.location_address,
        latitude=profile_in.latitude,
        longitude=profile_in.longitude,
        hourly_rate=profile_in.hourly_rate,
        experience_years=profile_in.experience_years,
        languages=profile_in.languages,
        qualifications=profile_in.qualifications,
        certificates=profile_in.certificates
    )
    db.add(new_therapist)
    await db.commit()
    await db.refresh(new_user)

    access_token = create_access_token(subject=str(new_user.id), role=new_user.role)
    refresh_token = create_refresh_token(subject=str(new_user.id))
    return Token(access_token=access_token, refresh_token=refresh_token, user=UserResponse.model_validate(new_user))

@router.post("/login", response_model=Token)
async def login(credentials: LoginRequest, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(User).where(User.email == credentials.email))
    user = result.scalars().first()
    if not user or not verify_password(credentials.password, user.password_hash):
        raise HTTPException(status_code=401, detail="Invalid email or password.")
    
    access_token = create_access_token(subject=str(user.id), role=user.role)
    refresh_token = create_refresh_token(subject=str(user.id))
    return Token(access_token=access_token, refresh_token=refresh_token, user=UserResponse.model_validate(user))

@router.post("/refresh", response_model=Token)
async def refresh_token(body: RefreshTokenRequest, db: AsyncSession = Depends(get_db)):
    payload = decode_token(body.refresh_token)
    if payload.get("type") != "refresh":
        raise HTTPException(status_code=400, detail="Invalid token type.")
    
    user_id = payload.get("sub")
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found.")

    access_token = create_access_token(subject=str(user.id), role=user.role)
    new_refresh_token = create_refresh_token(subject=str(user.id))
    return Token(access_token=access_token, refresh_token=new_refresh_token, user=UserResponse.model_validate(user))

async def get_current_user(token: str = Depends(oauth2_scheme), db: AsyncSession = Depends(get_db)) -> User:
    payload = decode_token(token)
    user_id = payload.get("sub")
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalars().first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found.")
    return user

@router.get("/me", response_model=UserResponse)
async def get_me(current_user: User = Depends(get_current_user)):
    return current_user
