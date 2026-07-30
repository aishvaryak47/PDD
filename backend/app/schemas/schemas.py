from pydantic import BaseModel, EmailStr, Field
from typing import Optional, List, Dict, Any
from datetime import datetime
from uuid import UUID

# User & Auth Schemas
class UserBase(BaseModel):
    email: EmailStr
    full_name: str
    role: Optional[str] = "client"

class UserCreate(UserBase):
    password: str

class UserResponse(UserBase):
    id: UUID
    avatar_url: Optional[str] = None
    is_active: bool
    created_at: datetime

    class Config:
        from_attributes = True

class Token(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: UserResponse

class LoginRequest(BaseModel):
    email: EmailStr
    password: str

class RefreshTokenRequest(BaseModel):
    refresh_token: str

# Client Profile
class ClientProfileCreate(BaseModel):
    phone: Optional[str] = None
    date_of_birth: Optional[str] = None
    emergency_contact_name: Optional[str] = None
    emergency_contact_phone: Optional[str] = None
    therapy_preferences: Optional[Dict[str, Any]] = None

class ClientResponse(BaseModel):
    id: UUID
    user_id: UUID
    phone: Optional[str] = None
    date_of_birth: Optional[str] = None
    emergency_contact_name: Optional[str] = None
    emergency_contact_phone: Optional[str] = None
    therapy_preferences: Optional[Dict[str, Any]] = None
    wellness_score: float
    user: UserResponse

    class Config:
        from_attributes = True

# Therapist Profile
class TherapistProfileCreate(BaseModel):
    title: str = "Licensed Clinical Psychologist"
    biography: str
    location_address: str
    latitude: float = 40.7128
    longitude: float = -74.0060
    hourly_rate: float = 120.00
    experience_years: int = 5
    languages: List[str] = ["English"]
    qualifications: List[str] = ["Psy.D in Clinical Psychology"]
    certificates: List[str] = ["APA Certified"]

class TherapistResponse(BaseModel):
    id: UUID
    user_id: UUID
    title: str
    biography: Optional[str] = None
    location_address: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    hourly_rate: float
    experience_years: int
    languages: List[str]
    qualifications: List[str]
    certificates: List[str]
    rating_avg: float
    total_reviews: int
    user: UserResponse

    class Config:
        from_attributes = True

# Appointment Schemas
class AppointmentCreate(BaseModel):
    therapist_id: UUID
    scheduled_at: datetime
    duration_minutes: int = 50
    notes: Optional[str] = None

class AppointmentResponse(BaseModel):
    id: UUID
    client_id: UUID
    therapist_id: UUID
    scheduled_at: datetime
    duration_minutes: int
    status: str
    price: float
    notes: Optional[str] = None
    created_at: datetime
    client: Optional[ClientResponse] = None
    therapist: Optional[TherapistResponse] = None

    class Config:
        from_attributes = True

# Mood Schemas
class MoodLogCreate(BaseModel):
    mood_score: int = Field(..., ge=1, le=5)
    emotion_tags: List[str] = []
    note: Optional[str] = None

class MoodLogResponse(BaseModel):
    id: UUID
    client_id: UUID
    mood_score: int
    emotion_tags: List[str]
    note: Optional[str] = None
    logged_at: datetime

    class Config:
        from_attributes = True

# Journal Schemas
class JournalCreate(BaseModel):
    title: str
    content: str
    audio_url: Optional[str] = None

class JournalResponse(BaseModel):
    id: UUID
    client_id: UUID
    title: str
    content: str
    audio_url: Optional[str] = None
    ai_summary: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True

# Message Schemas
class MessageCreate(BaseModel):
    receiver_id: UUID
    content: str
    attachment_url: Optional[str] = None
    message_type: str = "text"

class MessageResponse(BaseModel):
    id: UUID
    sender_id: UUID
    receiver_id: UUID
    content: str
    attachment_url: Optional[str] = None
    message_type: str
    is_read: bool
    timestamp: datetime

    class Config:
        from_attributes = True

# Review Schemas
class ReviewCreate(BaseModel):
    therapist_id: UUID
    rating: float = Field(..., ge=1.0, le=5.0)
    comment: Optional[str] = None

class ReviewResponse(BaseModel):
    id: UUID
    client_id: UUID
    therapist_id: UUID
    rating: float
    comment: Optional[str] = None
    created_at: datetime

    class Config:
        from_attributes = True

# AI Chat & Analysis Requests
class AIChatMessage(BaseModel):
    message: str
    context: Optional[str] = None

class AIChatResponse(BaseModel):
    reply: str
    disclaimer: str = "PSYNOVA AI provides supportive emotional guidance and is not a substitute for professional medical diagnosis or clinical crisis intervention."
