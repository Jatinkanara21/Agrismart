from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.orm import Session
from app.db import get_db
from app.models import User
from app.schemas import AuthData, AuthResponse, LoginRequest, UserCreate, UserResponse
from app.security import create_token, hash_password, verify_password

router = APIRouter(prefix="/auth")

@router.post("/register", response_model=AuthResponse, status_code=status.HTTP_201_CREATED)
def register(payload: UserCreate, db: Session = Depends(get_db)):
    if payload.password != payload.password_confirmation:
        raise HTTPException(status_code=422, detail="Passwords do not match.")
    if db.scalar(select(User).where(User.email == payload.email)):
        raise HTTPException(status_code=422, detail="Email is already registered.")
    user = User(name=payload.name, email=payload.email, password_hash=hash_password(payload.password))
    db.add(user)
    db.commit()
    db.refresh(user)
    return AuthResponse(message="Registration successful", data=AuthData(user=UserResponse.model_validate(user), token=create_token(user.id)))

@router.post("/login", response_model=AuthResponse)
def login(payload: LoginRequest, db: Session = Depends(get_db)):
    user = db.scalar(select(User).where(User.email == payload.email))
    if not user or not verify_password(payload.password, user.password_hash):
        raise HTTPException(status_code=422, detail="The provided credentials are incorrect.")
    return AuthResponse(message="Login successful", data=AuthData(user=UserResponse.model_validate(user), token=create_token(user.id)))

@router.post("/logout")
def logout():
    return {"success": True, "message": "Logged out successfully"}
