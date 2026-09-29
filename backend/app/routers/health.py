from fastapi import APIRouter, status
from fastapi.responses import JSONResponse
from sqlalchemy import text

from app.db import engine

router = APIRouter()


@router.get("/health")
def health():
    try:
        with engine.connect() as connection:
            connection.execute(text("SELECT 1"))
        return {
            "success": True,
            "service": "AgriSmart API",
            "status": "healthy",
            "database": "connected",
        }
    except Exception:
        return JSONResponse(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            content={
                "success": False,
                "service": "AgriSmart API",
                "status": "degraded",
                "database": "unavailable",
            },
        )
