import os

from fastapi import APIRouter, HTTPException
from openai import OpenAI
from pydantic import BaseModel, Field

router = APIRouter(prefix="/agribot", tags=["agribot"])


class ChatRequest(BaseModel):
    message: str = Field(min_length=1, max_length=2000)


class ChatResponse(BaseModel):
    reply: str
    model: str


def _client() -> OpenAI:
    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise HTTPException(
            status_code=503,
            detail="AgriBot AI is not configured on the backend.",
        )
    return OpenAI(api_key=api_key)


@router.post("/chat", response_model=ChatResponse)
def chat(payload: ChatRequest) -> ChatResponse:
    client = _client()
    model = os.getenv("OPENAI_MODEL", "gpt-5.6-luna")

    system_prompt = (
        "You are AgriBot, an agricultural decision-support assistant. "
        "Give concise, practical, safety-conscious farming guidance. "
        "Do not present model output as a guaranteed diagnosis, yield, or treatment. "
        "For serious crop disease, pesticide, fertilizer, or safety decisions, "
        "recommend confirmation with current field observations and qualified local agronomy guidance."
    )

    try:
        response = client.responses.create(
            model=model,
            instructions=system_prompt,
            input=payload.message,
            max_output_tokens=500,
        )
        reply = (response.output_text or "").strip()
    except Exception as exc:
        # Do not expose provider credentials or internal exception details.
        raise HTTPException(
            status_code=502,
            detail="The AgriBot provider request failed.",
        ) from exc

    if not reply:
        raise HTTPException(
            status_code=502,
            detail="The AgriBot provider returned an empty response.",
        )

    return ChatResponse(reply=reply, model=model)
