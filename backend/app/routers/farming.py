import httpx
from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from pydantic import BaseModel, Field

from app.core.config import settings
from app.routers.protected import current_user
from app.services.crop_recommender import CropModelError, recommend_crop

router = APIRouter()


class CropRecommendationRequest(BaseModel):
    nitrogen: float = Field(ge=0, le=300)
    phosphorus: float = Field(ge=0, le=300)
    potassium: float = Field(ge=0, le=300)
    temperature: float = Field(ge=-20, le=60)
    humidity: float = Field(ge=0, le=100)
    ph: float = Field(ge=0, le=14)
    rainfall: float = Field(ge=0, le=1000)


class YieldPredictionRequest(BaseModel):
    crop: str = Field(min_length=1, max_length=100)
    area: float = Field(gt=0)


class WeatherRequest(BaseModel):
    location: str = Field(min_length=2, max_length=100)


class AgriBotRequest(BaseModel):
    message: str = Field(min_length=1, max_length=4000)


class FarmingDecisionRequest(CropRecommendationRequest):
    location: str = Field(min_length=2, max_length=100)


async def geocode(location: str) -> tuple[float, float, str]:
    url = f"{settings.open_meteo_base_url.rstrip('/')}/geocoding/v1/search"
    async with httpx.AsyncClient(timeout=10) as client:
        response = await client.get(
            url,
            params={"name": location, "count": 1, "language": "en", "format": "json"},
        )
    response.raise_for_status()
    results = response.json().get("results") or []
    if not results:
        raise HTTPException(status_code=404, detail="Location was not found.")
    result = results[0]
    return float(result["latitude"]), float(result["longitude"]), result["name"]


async def get_weather(location: str) -> dict:
    latitude, longitude, resolved_name = await geocode(location)
    url = f"{settings.open_meteo_base_url.rstrip('/')}/v1/forecast"
    async with httpx.AsyncClient(timeout=10) as client:
        response = await client.get(
            url,
            params={
                "latitude": latitude,
                "longitude": longitude,
                "current": (
                    "temperature_2m,relative_humidity_2m,apparent_temperature,"
                    "precipitation,weather_code,wind_speed_10m"
                ),
                "daily": "temperature_2m_max,temperature_2m_min,precipitation_sum",
                "timezone": "auto",
                "forecast_days": 5,
            },
        )
    response.raise_for_status()
    payload = response.json()
    return {
        "location": resolved_name,
        "coordinates": {"latitude": latitude, "longitude": longitude},
        "current": payload.get("current", {}),
        "daily": payload.get("daily", {}),
        "provider": "Open-Meteo",
    }


@router.post("/crops/recommend")
def recommend_crop(payload: CropRecommendationRequest, user=Depends(current_user)):
    try:
        return {"success": True, "data": recommend_crop(payload.model_dump())}
    except CropModelError as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc


@router.post("/disease/detect")
async def detect_disease(image: UploadFile = File(...), user=Depends(current_user)):
    allowed = {"image/jpeg", "image/png", "image/webp"}
    if image.content_type not in allowed:
        raise HTTPException(
            status_code=422,
            detail="The image must be a JPG, JPEG, PNG, or WEBP file.",
        )
    content = await image.read()
    if len(content) > 5 * 1024 * 1024:
        raise HTTPException(status_code=422, detail="The image may not be larger than 5 MB.")

    if not settings.hf_token:
        raise HTTPException(
            status_code=503,
            detail="Disease detection needs HF_TOKEN with Inference Providers permission.",
        )

    # The selected model must be available through the configured inference provider.
    # We intentionally fail closed rather than returning a fabricated diagnosis.
    endpoint = (
        "https://router.huggingface.co/hf-inference/models/"
        f"{settings.hf_disease_model}"
    )
    async with httpx.AsyncClient(timeout=45) as client:
        response = await client.post(
            endpoint,
            headers={"Authorization": f"Bearer {settings.hf_token}"},
            content=content,
        )

    if response.status_code >= 400:
        raise HTTPException(
            status_code=502,
            detail=f"Disease provider returned HTTP {response.status_code}.",
        )

    result = response.json()
    if not isinstance(result, list) or not result:
        raise HTTPException(status_code=502, detail="Disease provider returned no prediction.")

    return {
        "success": True,
        "data": {
            "predictions": result[:3],
            "model": settings.hf_disease_model,
            "provider": "Hugging Face Inference Providers",
        },
    }


@router.post("/yield/predict")
def predict_yield(payload: YieldPredictionRequest, user=Depends(current_user)):
    raise HTTPException(
        status_code=503,
        detail=(
            "Yield prediction is not enabled yet because no validated yield dataset "
            "and trained yield model are configured. No estimate is fabricated."
        ),
    )


@router.get("/weather")
async def weather(location: str = "Ahmedabad", user=Depends(current_user)):
    try:
        return {"success": True, "data": await get_weather(location)}
    except httpx.HTTPError as exc:
        raise HTTPException(status_code=502, detail="Weather provider is unavailable.") from exc


@router.post("/agribot/chat")
async def agribot(payload: AgriBotRequest, user=Depends(current_user)):
    if not settings.hf_token or not settings.hf_chat_model:
        raise HTTPException(
            status_code=503,
            detail="AgriBot needs HF_TOKEN and HF_CHAT_MODEL provider configuration.",
        )

    endpoint = "https://router.huggingface.co/v1/chat/completions"
    async with httpx.AsyncClient(timeout=45) as client:
        response = await client.post(
            endpoint,
            headers={
                "Authorization": f"Bearer {settings.hf_token}",
                "Content-Type": "application/json",
            },
            json={
                "model": settings.hf_chat_model,
                "messages": [
                    {
                        "role": "system",
                        "content": (
                            "You are AgriBot, an agricultural decision-support assistant. "
                            "Give practical, cautious farming information. Do not claim "
                            "certainty or diagnose a crop disease from text alone."
                        ),
                    },
                    {"role": "user", "content": payload.message},
                ],
                "stream": False,
            },
        )

    if response.status_code >= 400:
        raise HTTPException(status_code=502, detail="AI provider request failed.")

    data = response.json()
    answer = ((data.get("choices") or [{}])[0].get("message") or {}).get("content")
    if not answer:
        raise HTTPException(status_code=502, detail="AI provider returned no answer.")

    return {"success": True, "data": {"answer": answer, "model": settings.hf_chat_model}}


@router.post("/farming/decision")
def farming_decision(payload: FarmingDecisionRequest, user=Depends(current_user)):
    try:
        crop = recommend_crop(payload.model_dump(exclude={"location"}))
    except CropModelError as exc:
        raise HTTPException(status_code=503, detail=str(exc)) from exc

    return {
        "success": True,
        "data": {
            "location": payload.location,
            "recommended_crop": crop["recommendation"],
            "confidence": crop["confidence"],
            "alternatives": crop["alternatives"],
            "actions": [
                "Validate soil test values before planting.",
                "Compare the recommendation with local agronomy guidance.",
                "Use current weather and irrigation conditions before acting.",
            ],
            "model": crop["model"],
        },
    }
