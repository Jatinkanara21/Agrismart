# 🌱 AgriSmart — AI-Powered Smart Farming Assistant

AgriSmart is a farmer-focused platform combining a Flutter mobile application, Laravel API, MySQL, and Python machine-learning services.

## Architecture

Flutter → Laravel API → MySQL / ML service → external AI & weather providers

## Repository

- `mobile/` — Flutter application
- `backend/` — Laravel API
- `ml/` — Python inference/training foundation
- `docs/` — project documentation
- `.github/workflows/` — CI

## Important integrity rule

AgriSmart never invents an ML prediction. If a trained model or external service is not configured, the API reports that capability as unavailable.

## Quick start

See [docs/setup.md](docs/setup.md).

## Documentation

- [Architecture](docs/architecture.md)
- [Setup](docs/setup.md)
- [API](docs/api.md)
- [ML](docs/ml.md)
- [Deployment](docs/deployment.md)
- [Troubleshooting](docs/troubleshooting.md)
