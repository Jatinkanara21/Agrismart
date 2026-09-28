from fastapi import APIRouter, Depends, Header, HTTPException
from jose import JWTError, jwt
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.core.config import settings
from app.db import get_db
from app.models import User

router = APIRouter()

def current_user(authorization: str | None = Header(default=None), db: Session = Depends(get_db)):
    if not authorization or not authorization.startswith("Bearer "):
        raise HTTPException(status_code=401, detail="Authentication required.")
    try:
        payload = jwt.decode(authorization[7:], settings.jwt_secret, algorithms=[settings.jwt_algorithm])
        user_id = int(payload["sub"])
    except (JWTError, KeyError, ValueError):
        raise HTTPException(status_code=401, detail="Invalid or expired token.")
    user = db.scalar(select(User).where(User.id == user_id))
    if not user:
        raise HTTPException(status_code=401, detail="User not found.")
    return user

@router.get("/user")
def user(user: User = Depends(current_user)):
    return {"success": True, "message": "User retrieved", "data": {"id": user.id, "name": user.name, "email": user.email}}

@router.get("/dashboard")
def dashboard(user: User = Depends(current_user)):
    return {"success": True, "data": {"user": {"id": user.id, "name": user.name, "email": user.email}}}
