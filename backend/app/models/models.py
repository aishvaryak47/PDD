import uuid
from datetime import datetime
from sqlalchemy import Column, String, Boolean, DateTime, Integer, Float, Numeric, ForeignKey, Text, JSON
from sqlalchemy.orm import relationship
from sqlalchemy import UUID
from app.db.database import Base

class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), unique=True, index=True, nullable=False)
    password_hash = Column(String(255), nullable=False)
    full_name = Column(String(255), nullable=False)
    role = Column(String(50), nullable=False) # "client" or "therapist"
    avatar_url = Column(String(512), nullable=True)
    is_active = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    client_profile = relationship("Client", back_populates="user", uselist=False, cascade="all, delete-orphan")
    therapist_profile = relationship("Therapist", back_populates="user", uselist=False, cascade="all, delete-orphan")
    notifications = relationship("Notification", back_populates="user", cascade="all, delete-orphan")

class Client(Base):
    __tablename__ = "clients"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, unique=True)
    phone = Column(String(50), nullable=True)
    date_of_birth = Column(String(50), nullable=True)
    emergency_contact_name = Column(String(255), nullable=True)
    emergency_contact_phone = Column(String(50), nullable=True)
    therapy_preferences = Column(JSON, nullable=True) # e.g. {"topics": ["Anxiety", "Depression"], "format": "Video"}
    wellness_score = Column(Float, default=78.5)

    user = relationship("User", back_populates="client_profile")
    appointments = relationship("Appointment", back_populates="client")
    mood_logs = relationship("MoodLog", back_populates="client")
    journals = relationship("Journal", back_populates="client")
    reviews = relationship("Review", back_populates="client")

class Therapist(Base):
    __tablename__ = "therapists"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, unique=True)
    title = Column(String(255), nullable=False, default="Licensed Clinical Psychologist")
    biography = Column(Text, nullable=True)
    location_address = Column(String(512), nullable=True, default="Downtown Medical Center, NY")
    latitude = Column(Float, nullable=True, default=40.7128)
    longitude = Column(Float, nullable=True, default=-74.0060)
    hourly_rate = Column(Numeric(10, 2), nullable=False, default=120.00)
    experience_years = Column(Integer, default=5)
    languages = Column(JSON, default=["English"])
    qualifications = Column(JSON, default=["Psy.D in Clinical Psychology", "Licensed CBT Specialist"])
    certificates = Column(JSON, default=["APA Certified Therapist"])
    rating_avg = Column(Float, default=4.9)
    total_reviews = Column(Integer, default=24)

    user = relationship("User", back_populates="therapist_profile")
    appointments = relationship("Appointment", back_populates="therapist")
    availabilities = relationship("Availability", back_populates="therapist")
    reviews = relationship("Review", back_populates="therapist")
    revenues = relationship("Revenue", back_populates="therapist")

class Appointment(Base):
    __tablename__ = "appointments"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    client_id = Column(UUID(as_uuid=True), ForeignKey("clients.id", ondelete="CASCADE"), nullable=False)
    therapist_id = Column(UUID(as_uuid=True), ForeignKey("therapists.id", ondelete="CASCADE"), nullable=False)
    scheduled_at = Column(DateTime, nullable=False)
    duration_minutes = Column(Integer, default=50)
    status = Column(String(50), default="pending") # pending, accepted, rejected, completed, cancelled
    price = Column(Numeric(10, 2), nullable=False)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    client = relationship("Client", back_populates="appointments")
    therapist = relationship("Therapist", back_populates="appointments")
    session_notes = relationship("SessionNotes", back_populates="appointment", uselist=False)

class Availability(Base):
    __tablename__ = "availabilities"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    therapist_id = Column(UUID(as_uuid=True), ForeignKey("therapists.id", ondelete="CASCADE"), nullable=False)
    day_of_week = Column(String(20), nullable=False) # Monday, Tuesday, etc.
    start_time = Column(String(10), nullable=False) # "09:00"
    end_time = Column(String(10), nullable=False) # "17:00"

    therapist = relationship("Therapist", back_populates="availabilities")

class MoodLog(Base):
    __tablename__ = "mood_logs"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    client_id = Column(UUID(as_uuid=True), ForeignKey("clients.id", ondelete="CASCADE"), nullable=False)
    mood_score = Column(Integer, nullable=False) # 1 (Lowest) to 5 (Highest)
    emotion_tags = Column(JSON, nullable=True) # ["Calm", "Anxious", "Grateful"]
    note = Column(Text, nullable=True)
    logged_at = Column(DateTime, default=datetime.utcnow)

    client = relationship("Client", back_populates="mood_logs")

class Journal(Base):
    __tablename__ = "journals"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    client_id = Column(UUID(as_uuid=True), ForeignKey("clients.id", ondelete="CASCADE"), nullable=False)
    title = Column(String(255), nullable=False)
    content = Column(Text, nullable=False)
    audio_url = Column(String(512), nullable=True)
    ai_summary = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    client = relationship("Client", back_populates="journals")

class Message(Base):
    __tablename__ = "messages"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    sender_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    receiver_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    content = Column(Text, nullable=False)
    attachment_url = Column(String(512), nullable=True)
    message_type = Column(String(50), default="text") # text, image, file, audio
    is_read = Column(Boolean, default=False)
    timestamp = Column(DateTime, default=datetime.utcnow)

class Review(Base):
    __tablename__ = "reviews"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    client_id = Column(UUID(as_uuid=True), ForeignKey("clients.id", ondelete="CASCADE"), nullable=False)
    therapist_id = Column(UUID(as_uuid=True), ForeignKey("therapists.id", ondelete="CASCADE"), nullable=False)
    rating = Column(Float, nullable=False)
    comment = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    client = relationship("Client", back_populates="reviews")
    therapist = relationship("Therapist", back_populates="reviews")

class Revenue(Base):
    __tablename__ = "revenues"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    therapist_id = Column(UUID(as_uuid=True), ForeignKey("therapists.id", ondelete="CASCADE"), nullable=False)
    appointment_id = Column(UUID(as_uuid=True), ForeignKey("appointments.id", ondelete="CASCADE"), nullable=False)
    amount = Column(Numeric(10, 2), nullable=False)
    status = Column(String(50), default="completed")
    date = Column(DateTime, default=datetime.utcnow)

    therapist = relationship("Therapist", back_populates="revenues")

class Notification(Base):
    __tablename__ = "notifications"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    title = Column(String(255), nullable=False)
    body = Column(Text, nullable=False)
    type = Column(String(50), default="info") # appointment, chat, ai, mood, info
    is_read = Column(Boolean, default=False)
    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship("User", back_populates="notifications")

class SessionNotes(Base):
    __tablename__ = "session_notes"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    appointment_id = Column(UUID(as_uuid=True), ForeignKey("appointments.id", ondelete="CASCADE"), nullable=False, unique=True)
    therapist_id = Column(UUID(as_uuid=True), ForeignKey("therapists.id", ondelete="CASCADE"), nullable=False)
    client_id = Column(UUID(as_uuid=True), ForeignKey("clients.id", ondelete="CASCADE"), nullable=False)
    content = Column(Text, nullable=False)
    ai_summary = Column(Text, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow)

    appointment = relationship("Appointment", back_populates="session_notes")
