from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.future import select
from typing import List
from uuid import UUID
from app.db.database import get_db
from app.models.models import Message, User
from app.schemas.schemas import MessageCreate, MessageResponse
from app.api.v1.auth import get_current_user
from app.services.websocket_manager import ws_manager

router = APIRouter(prefix="/chat", tags=["Direct Messaging"])

@router.post("", response_model=MessageResponse)
async def send_direct_message(
    msg_in: MessageCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    receiver_res = await db.execute(select(User).where(User.id == msg_in.receiver_id))
    if not receiver_res.scalars().first():
        raise HTTPException(status_code=404, detail="Receiver user not found.")

    new_msg = Message(
        sender_id=current_user.id,
        receiver_id=msg_in.receiver_id,
        content=msg_in.content,
        attachment_url=msg_in.attachment_url,
        message_type=msg_in.message_type
    )
    db.add(new_msg)
    await db.commit()
    await db.refresh(new_msg)

    # Broadcast via WebSocket if online
    await ws_manager.send_to_user(
        str(msg_in.receiver_id),
        {
            "type": "new_message",
            "message": {
                "id": str(new_msg.id),
                "sender_id": str(new_msg.sender_id),
                "content": new_msg.content,
                "timestamp": new_msg.timestamp.isoformat()
            }
        }
    )

    return new_msg

@router.get("/conversation/{other_user_id}", response_model=List[MessageResponse])
async def get_conversation(
    other_user_id: UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db)
):
    query = select(Message).where(
        ((Message.sender_id == current_user.id) & (Message.receiver_id == other_user_id)) |
        ((Message.sender_id == other_user_id) & (Message.receiver_id == current_user.id))
    ).order_by(Message.timestamp.asc())
    
    res = await db.execute(query)
    return res.scalars().all()
