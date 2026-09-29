from app.routers.health import health
from app.security import hash_password, verify_password


def test_health_reports_database_connection():
    response = health()
    assert response["success"] is True
    assert response["status"] == "healthy"
    assert response["database"] == "connected"


def test_password_hash_round_trip():
    password = "AgriSmart-test-password"
    password_hash = hash_password(password)

    assert password_hash != password
    assert verify_password(password, password_hash)
    assert not verify_password("wrong-password", password_hash)


from app.services.crop_recommender import recommend_crop


def test_crop_recommendation_model_returns_result():
    result = recommend_crop({
        "N": 90,
        "P": 42,
        "K": 43,
        "temperature": 21,
        "humidity": 82,
        "ph": 6.5,
        "rainfall": 203,
    })
    assert result["recommendation"] == "rice"
    assert 0 <= result["confidence"] <= 100
    assert len(result["alternatives"]) == 2
