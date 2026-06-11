from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
from app.schemas.auth import UserResponse

class MessageBase(BaseModel):
    text: str

class MessageCreate(MessageBase):
    room_id: int

class MessageResponse(MessageBase):
    id: int
    room_id: int
    sender_id: int
    is_read: bool
    created_at: datetime
    sender: Optional[UserResponse] = None

    class Config:
        from_attributes = True

class ChatRoomBase(BaseModel):
    product_id: int
    seller_id: int

class ChatRoomCreate(ChatRoomBase):
    pass

class ChatRoomResponse(ChatRoomBase):
    id: int
    buyer_id: int
    created_at: datetime
    buyer: Optional[UserResponse] = None
    seller: Optional[UserResponse] = None
    messages: List[MessageResponse] = []

    class Config:
        from_attributes = True
