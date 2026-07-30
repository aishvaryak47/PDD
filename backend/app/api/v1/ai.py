from fastapi import APIRouter, Depends
from app.schemas.schemas import AIChatMessage, AIChatResponse
from app.api.v1.auth import get_current_user
from app.models.models import User
from app.services.groq_service import groq_service

router = APIRouter(prefix="/ai", tags=["AI Mental Health Assistant"])

@router.post("/chat", response_model=AIChatResponse)
async def ai_chat_assistant(
    body: AIChatMessage,
    current_user: User = Depends(get_current_user)
):
    reply = await groq_service.generate_chat_response(body.message, user_role=current_user.role)
    return AIChatResponse(
        reply=reply,
        disclaimer="PSYNOVA AI provides supportive guidance and is not a medical diagnosis tool or clinical emergency service."
    )
