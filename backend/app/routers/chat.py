from fastapi import APIRouter, Depends, WebSocket, WebSocketDisconnect, HTTPException, status
from sqlalchemy.orm import Session
from sqlalchemy import or_
from typing import List, Dict
import json
from app.core.database import get_db, SessionLocal
from app.core.dependencies import get_current_user
from app.models.user import User
from app.models.chat import ChatRoom, Message
from app.schemas.auth import BaseResponse
from app.schemas.chat import ChatRoomResponse, MessageResponse
from app.core.config import settings
from jose import jwt, JWTError

router = APIRouter()

class ConnectionManager:
    def __init__(self):
        # user_id -> List of WebSockets (user might have multiple devices)
        self.active_connections: Dict[int, List[WebSocket]] = {}

    async def connect(self, websocket: WebSocket, user_id: int):
        await websocket.accept()
        if user_id not in self.active_connections:
            self.active_connections[user_id] = []
        self.active_connections[user_id].append(websocket)

    def disconnect(self, websocket: WebSocket, user_id: int):
        if user_id in self.active_connections:
            self.active_connections[user_id].remove(websocket)
            if not self.active_connections[user_id]:
                del self.active_connections[user_id]

    async def send_personal_message(self, message: dict, user_id: int):
        if user_id in self.active_connections:
            for connection in self.active_connections[user_id]:
                await connection.send_text(json.dumps(message))

manager = ConnectionManager()

def get_user_from_token(token: str, db: Session) -> User:
    try:
        payload = jwt.decode(token, settings.SECRET_KEY, algorithms=[settings.ALGORITHM])
        user_id: str = payload.get("sub")
        if user_id is None:
            return None
        return db.query(User).filter(User.id == int(user_id)).first()
    except (JWTError, ValueError):
        return None


@router.get("/rooms", response_model=BaseResponse[List[ChatRoomResponse]])
def get_user_rooms(db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):
    """
    Get all chat rooms for the current user (either as buyer or seller)
    """
    rooms = db.query(ChatRoom).filter(
        or_(ChatRoom.buyer_id == current_user.id, ChatRoom.seller_id == current_user.id)
    ).all()
    return BaseResponse(data=rooms)


@router.post("/rooms", response_model=BaseResponse[ChatRoomResponse])
def get_or_create_room(
    product_id: int, 
    seller_id: int, 
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_user)
):
    """
    Create a new chat room or get existing one for a product between buyer and seller
    """
    if seller_id == current_user.id:
        raise HTTPException(status_code=400, detail="Cannot create chat room with yourself")

    room = db.query(ChatRoom).filter(
        ChatRoom.product_id == product_id,
        ChatRoom.buyer_id == current_user.id,
        ChatRoom.seller_id == seller_id
    ).first()

    if not room:
        room = ChatRoom(product_id=product_id, buyer_id=current_user.id, seller_id=seller_id)
        db.add(room)
        db.commit()
        db.refresh(room)

    return BaseResponse(data=room)


@router.get("/rooms/{room_id}/messages", response_model=BaseResponse[List[MessageResponse]])
def get_room_messages(
    room_id: int, 
    db: Session = Depends(get_db), 
    current_user: User = Depends(get_current_user)
):
    """
    Get message history for a specific chat room
    """
    room = db.query(ChatRoom).filter(ChatRoom.id == room_id).first()
    if not room:
        raise HTTPException(status_code=404, detail="Room not found")
    
    if current_user.id not in [room.buyer_id, room.seller_id]:
        raise HTTPException(status_code=403, detail="Not authorized to view this room")

    messages = db.query(Message).filter(Message.room_id == room_id).order_by(Message.created_at.asc()).all()
    
    # Mark messages as read
    unread_messages = [m for m in messages if m.sender_id != current_user.id and not m.is_read]
    for msg in unread_messages:
        msg.is_read = True
    if unread_messages:
        db.commit()

    return BaseResponse(data=messages)


@router.websocket("/ws/{token}")
async def websocket_endpoint(websocket: WebSocket, token: str):
    db = SessionLocal()
    user = get_user_from_token(token, db)
    
    if not user:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        db.close()
        return

    await manager.connect(websocket, user.id)
    try:
        while True:
            data = await websocket.receive_text()
            message_data = json.loads(data)
            room_id = message_data.get("room_id")
            text = message_data.get("text")
            
            if not room_id or not text:
                continue
                
            room = db.query(ChatRoom).filter(ChatRoom.id == room_id).first()
            if not room or user.id not in [room.buyer_id, room.seller_id]:
                continue
                
            # Create message in DB
            new_msg = Message(room_id=room_id, sender_id=user.id, text=text)
            db.add(new_msg)
            db.commit()
            db.refresh(new_msg)
            
            # Determine receiver
            receiver_id = room.seller_id if user.id == room.buyer_id else room.buyer_id
            
            # Format message for sending
            response_msg = {
                "id": new_msg.id,
                "room_id": new_msg.room_id,
                "sender_id": new_msg.sender_id,
                "text": new_msg.text,
                "created_at": new_msg.created_at.isoformat(),
            }
            
            # Send to receiver and sender (to acknowledge)
            await manager.send_personal_message(response_msg, receiver_id)
            await manager.send_personal_message(response_msg, user.id)

    except WebSocketDisconnect:
        manager.disconnect(websocket, user.id)
    finally:
        db.close()
