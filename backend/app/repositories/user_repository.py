from typing import Optional
from sqlalchemy.orm import Session
from sqlalchemy import or_
from app.models.user import User, UserSession

class UserRepository:
    def __init__(self, db: Session):
        self.db = db

    def get_user_by_identity(self, identity: str) -> Optional[User]:
        """Finds a user by email or phone number."""
        return self.db.query(User).filter(
            or_(User.email == identity, User.phone == identity)
        ).first()

    def get_user_by_id(self, user_id: int) -> Optional[User]:
        """Finds a user by their unique ID."""
        return self.db.query(User).filter(User.id == user_id).first()

    def create_user(self, user: User) -> User:
        """Persists a new user to the database."""
        try:
            self.db.add(user)
            self.db.commit()
            self.db.refresh(user)
            return user
        except Exception:
            self.db.rollback()
            raise

    def update_user_pin(self, user_id: int, hashed_pin: str):
        """Updates the user's PIN hash."""
        user = self.get_user_by_id(user_id)
        if user:
            user.hashed_pin = hashed_pin
            self.db.commit()

    def create_session(self, session: UserSession):
        """Saves a new user session."""
        self.db.add(session)
        self.db.commit()

    def get_session_by_hash(self, token_hash: str) -> Optional[UserSession]:
        """Finds an active session by the hash of the refresh token."""
        return self.db.query(UserSession).filter(
            UserSession.refresh_token_hash == token_hash,
            UserSession.is_revoked == False
        ).first()

    def revoke_session_by_token_hash(self, token_hash: str):
        """Revokes a session using the refresh token hash."""
        session = self.db.query(UserSession).filter(
            UserSession.refresh_token_hash == token_hash
        ).first()
        if session:
            session.is_revoked = True
            self.db.commit()

    def revoke_all_user_sessions(self, user_id: int):
        """Revokes all active sessions for a specific user."""
        self.db.query(UserSession).filter(
            UserSession.user_id == user_id,
            UserSession.is_revoked == False
        ).update({"is_revoked": True})
        self.db.commit()
