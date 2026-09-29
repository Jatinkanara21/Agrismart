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
