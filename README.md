# 🌱 AgriSmart — AI-Powered Smart Farming Assistant

AgriSmart combines a Flutter mobile application, a Python FastAPI backend, MySQL, and Python machine-learning services.

## Architecture

Flutter → FastAPI → MySQL / ML service → external AI & weather providers

## Repository

- `mobile/` — Flutter application
- `backend/` — FastAPI API
- `ml/` — Python inference/training foundation
- `docs/` — project documentation
- `.github/workflows/` — CI and GitHub Pages deployment

## API

The versioned API is exposed under `/api/v1`: authentication, user/dashboard, crop recommendation, plant disease detection, yield prediction, weather, AgriBot, and farming decision workflows.

Model/provider endpoints return HTTP 503 when the required production model or provider is not configured. AgriSmart never invents an ML prediction.

## Documentation

- [Architecture](docs/architecture.md)
- [Setup](docs/setup.md)
- [API](docs/api.md)
- [ML](docs/ml.md)
- [Deployment](docs/deployment.md)
- [Troubleshooting](docs/troubleshooting.md)
