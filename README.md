# PSYNOVA AI – Intelligent Mental Health & Therapy Platform

PSYNOVA AI is a production-ready, cross-platform AI-powered digital mental health ecosystem built with **Flutter** for multi-platform frontend deployment (iOS, Android, Web, Windows, macOS, Linux) and **Python FastAPI** + **PostgreSQL** for the backend engine.

---

## 🌟 Primary Features

### 👤 Client Features
- **Authentication & Roles**: Client registration, login, auto-token refresh & role-based routing.
- **AI Mental Health Companion**: 24/7 Groq AI assistant providing 4-7-8 breathing exercises, anxiety coping strategies, and daily motivation (with explicit medical disclaimers).
- **Nearby Therapists & Maps**: Discover licensed practitioners, view location maps, filter by hourly rate, qualifications, and ratings.
- **Appointment System**: Book 50-minute HD therapy sessions, pick calendar dates & time slots.
- **HD WebRTC Video Consultation**: Live video call room with remote/local video streams, session timers, mic/video toggles, and direct messaging.
- **Daily Mood Check-in & Analytics**: Track emotional states on an interactive 1-5 slider, tag emotions, view `fl_chart` weekly trends, and receive AI wellness insights.
- **Personal Journal**: Rich text & voice notes with automatic Groq AI emotion & summary generation.

### 🩺 Therapist Features
- **Clinical Dashboard**: Overview of today's schedule, active client count, monthly earnings, and AI pre-session client alerts.
- **Appointment Management**: Accept or reject incoming booking requests, manage custom time slots.
- **Client Management**: Search client profiles, review therapy history, edit clinical SOAP notes with AI session summarization.
- **Revenue Analytics**: Visual `fl_chart` bar chart breakdown of weekly and monthly consultation earnings.
- **Professional Profile**: Manage title, fee rates, languages, and qualifications.

---

## 🏗️ Project Architecture

```
PDD/
├── backend/                  # Python FastAPI Backend
│   ├── app/
│   │   ├── api/v1/          # Auth, Therapists, Appointments, Mood, Journal, AI, Chat
│   │   ├── core/            # Config, Security (JWT, bcrypt)
│   │   ├── db/              # SQLAlchemy Async & PostgreSQL
│   │   ├── models/          # ORM Models (Users, Clients, Therapists, Appointments, etc.)
│   │   ├── schemas/         # Pydantic V2 schemas
│   │   ├── services/        # Groq AI Service, WebSocket Connection Manager
│   │   └── main.py          # FastAPI Server Entry & WebSockets
│   ├── Dockerfile
│   └── requirements.txt
│
└── lib/                      # Flutter Multi-Platform App
    ├── core/
    │   ├── config/          # Routes (GoRouter), AppTheme (Material 3)
    │   ├── constants/       # AppColors design system tokens
    │   └── network/         # ApiClient (Dio + JWT Interceptor)
    ├── features/
    │   ├── ai_assistant/    # Groq AI Chat & Coping Exercises
    │   ├── appointments/    # Booking & Schedule Management
    │   ├── auth/            # Login, Registration, Onboarding
    │   ├── client_dashboard/# Client Main Shell & Wellness Index
    │   ├── journal/         # Personal Journaling & AI Summaries
    │   ├── messaging/       # Real-Time WebSocket Direct Chat
    │   ├── mood_tracker/    # Daily Check-in & fl_chart Graphs
    │   ├── therapist_dashboard/ # Clinical Shell, Revenue & Client Management
    │   ├── therapist_discovery/ # Google Maps Nearby Therapists
    │   └── video_consultation/  # WebRTC Video Consultation Room
    ├── shared/              # Models & Reusable Glassmorphism Widgets
    └── main.dart
```

---

## 🚀 Getting Started

### 1. Launching the Backend
```bash
cd backend
python -m venv venv
# On Windows:
.\venv\Scripts\activate
# On Linux/macOS:
source venv/bin/activate

pip install -r requirements.txt
uvicorn app.main:app --reload --port 8000
```
API Documentation will be available at `http://localhost:8000/docs`.

### 2. Launching the Flutter Frontend
```bash
flutter pub get
flutter run
```

Targets supported out-of-the-box:
- Chrome / Web (`flutter run -d chrome`)
- Windows Desktop (`flutter run -d windows`)
- Android / iOS Emulators
- macOS / Linux Desktop
