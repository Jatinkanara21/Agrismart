from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from pydantic import BaseModel, Field
from app.routers.protected import current_user

router = APIRouter()


def unavailable(message: str):
    raise HTTPException(status_code=503, detail=message)


class CropRecommendationRequest(BaseModel):
    nitrogen: float
    phosphorus: float
    potassium: float
    temperature: float
    humidity: float
    ph: float
    rainfall: float


class YieldPredictionRequest(BaseModel):
    crop: str = Field(min_length=1, max_length=100)
    area: float = Field(ge=0)


class AgriBotRequest(BaseModel):
    message: str = Field(min_length=1, max_length=4000)


class FarmingDecisionRequest(BaseModel):
    crop: str | None = Field(default=None, max_length=100)
    location: str | None = Field(default=None, max_length=255)
    season: str | None = Field(default=None, max_length=100)


@router.post("/crops/recommend")
def recommend_crop(payload: CropRecommendationRequest, user=Depends(current_user)):
    unavailable(
        "Crop recommendation model is not configured. Configure a trained ML service before requesting production predictions."
    )


@router.post("/disease/detect")
async def detect_disease(image: UploadFile = File(...), user=Depends(current_user)):
    allowed = {"image/jpeg", "image/png", "image/webp"}
    if image.content_type not in allowed:
        raise HTTPException(status_code=422, detail="The image must be a JPG, JPEG, PNG, or WEBP file.")
    content = await image.read()
    if len(content) > 5 * 1024 * 1024:
        raise HTTPException(status_code=422, detail="The image may not be larger than 5 MB.")
    unavailable(
        "Disease detection model is not configured. Configure a trained ML service before requesting production predictions."
    )


@router.post("/yield/predict")
def predict_yield(payload: YieldPredictionRequest, user=Depends(current_user)):
    unavailable(
        "Yield prediction model is not configured. Configure a trained ML service before requesting production predictions."
    )


@router.get("/weather")
def weather(user=Depends(current_user)):
    unavailable("Weather provider is not configured. Set WEATHER_API_KEY and provider configuration.")


@router.post("/agribot/chat")
def agribot(payload: AgriBotRequest, user=Depends(current_user)):
    unavailable("AgriBot provider is not configured. Set the backend AI provider before enabling production chat.")


@router.post("/farming/decision")
def farming_decision(payload: FarmingDecisionRequest, user=Depends(current_user)):
    unavailable("Decision engine is not configured with its required data providers/models.")
