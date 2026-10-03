from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
import httpx

from app.core.config import settings

router = APIRouter(prefix="/agribot", tags=["agribot"])


class ChatRequest(BaseModel):
    message: str = Field(min_length=1, max_length=2000)


class ChatResponse(BaseModel):
    reply: str
    model: str


@router.post("/chat", response_model=ChatResponse)
def chat(payload: ChatRequest) -> ChatResponse:
    if not settings.ollama_api_key:
        raise HTTPException(
            status_code=503,
            detail="AgriBot AI is not configured on the backend.",
        )

    system_prompt = (
        "You are AgriBot, an agricultural decision-support assistant. "
        "Give concise, practical, safety-conscious farming guidance. "
        "Do not present model output as a guaranteed diagnosis, yield, or treatment. "
        "For serious crop disease, pesticide, fertilizer, or safety decisions, "
        "recommend confirmation with current field observations and qualified local agronomy guidance."
    )

    try:
        response = httpx.post(
            f"{settings.ollama_base_url.rstrip('/')}/chat",
            headers={
                "Authorization": f"Bearer {settings.ollama_api_key}",
                "Content-Type": "application/json",
            },
            json={
                "model": settings.ollama_model,
                "messages": [
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": payload.message},
                ],
                "stream": False,
            },
            timeout=60.0,
        )
        response.raise_for_status()
        data = response.json()
        message = data.get("message") or {}
        reply = (message.get("content") or "").strip()
    except (httpx.HTTPError, ValueError) as exc:
        raise HTTPException(
            status_code=502,
            detail="The Ollama Cloud provider request failed.",
        ) from exc

    if not reply:
        raise HTTPException(
            status_code=502,
            detail="Ollama Cloud returned an empty response.",
        )

    return ChatResponse(reply=reply, model=settings.ollama_model)
