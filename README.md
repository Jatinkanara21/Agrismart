# 🌱 AgriSmart — AI-Powered Smart Farming Assistant

AgriSmart is a smart-agriculture platform with a Flutter application, Python FastAPI backend, and a Python ML foundation for model-backed farming features.

> **Architecture note:** The current repository uses **FastAPI instead of Laravel**. Laravel was intentionally removed during the backend migration, so this repository is not being reverted to Laravel without a separate architecture decision.

## Features

- Farmer authentication and dashboard
- Crop recommendation API contract
- Plant disease detection API contract
- Yield prediction API contract
- AgriBot API contract
- Weather API contract
- Smart farming decision API contract
- Flutter Web deployment to GitHub Pages
- Python ML inference/training foundation
- Explicit 503 responses when a required real model/provider is not configured

## Architecture

```text
Flutter
   │ HTTPS
   ▼
FastAPI /api/v1
   │
   ├── SQLAlchemy + MySQL (production configuration)
   ├── Python ML services
   └── External AI / weather providers
```

GitHub Pages hosts the Flutter Web frontend. The FastAPI service is deployed separately on Python-capable hosting.

## Repository Structure

```text
AgriSmart/
├── backend/                 # FastAPI API
│   ├── app/
│   ├── tests/
│   ├── requirements.txt
│   └── .env.example
├── mobile/                  # Flutter application
│   ├── lib/
│   ├── test/
│   └── pubspec.yaml
├── ml/                      # ML foundation
│   ├── inference/
│   ├── preprocessing/
│   ├── evaluation/
│   ├── training/
│   └── tests/
├── docs/                    # Architecture, setup, API, ML and deployment docs
└── .github/workflows/       # CI and GitHub Pages deployment
```

## Technology Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter / Dart |
| Backend | Python / FastAPI |
| ORM | SQLAlchemy |
| Database | MySQL in production configuration; SQLite fallback for initial Render startup |
| Authentication | JWT + bcrypt |
| ML | Python, NumPy, scikit-learn, Pillow |
| CI/CD | GitHub Actions |
| Web hosting | GitHub Pages |
| API hosting | Render |

## Local Setup

### Backend

```bash
cd backend
python -m venv .venv
# Windows
.venv\\Scripts\\activate
# macOS/Linux
source .venv/bin/activate

pip install -r requirements.txt
uvicorn main:app --reload --port 8000
```

Configure `backend/.env.example` as `.env` and provide a real database URL and JWT secret.

### Flutter

```bash
cd mobile
flutter pub get
flutter analyze
flutter test
flutter build web --release --base-href "/Agrismart/"
```

For Flutter Web, provide `API_BASE_URL` at build time:

```bash
flutter build web --release --base-href "/Agrismart/" --dart-define=API_BASE_URL="https://YOUR-BACKEND/api/v1"
```

### ML

```bash
cd ml
python -m venv .venv
pip install -r requirements.txt
python -m compileall .
pytest
```

Model artifacts and datasets are intentionally not committed by default.

## API

The versioned API is exposed under `/api/v1`.

- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/logout`
- `GET /user`
- `GET /dashboard`
- `GET /health`
- `POST /crops/recommend`
- `POST /disease/detect`
- `POST /yield/predict`
- `GET /weather`
- `POST /agribot/chat`
- `POST /farming/decision`

Prediction/provider endpoints return HTTP 503 until their real model or provider is configured. The application does not fabricate predictions.

## Bundled Demo Data

The repository now includes transparent local demo datasets for disease detection, yield prediction, and farming guidance under `backend/data/`. Flutter also includes a small local demo-data layer so the UI can be explored without provider credentials. Demo values are labeled as demonstration/decision-support data and are not presented as live agronomic measurements.

## Testing

The GitHub Actions pipelines currently verify:

- FastAPI source compilation, application import, pytest suite and required routes
- Flutter dependency resolution, formatting, static analysis, widget tests and Web release build
- ML source compilation and pytest smoke tests

## Deployment

### Flutter Web

GitHub Pages deploys the Flutter Web artifact from `mobile/build/web` using `.github/workflows/pages.yml`.

Production API configuration uses the `AGRISMART_API_URL` GitHub Actions variable when available. The current workflow has a fallback to the deployed AgriSmart Render API.

### FastAPI

The current Render service runs:

```text
pip install -r requirements.txt
uvicorn main:app --host 0.0.0.0 --port $PORT
```

Current deployed API host:

```text
https://agrismart-api-bcbu.onrender.com
```

The current Render service uses the SQLite fallback because a persistent MySQL connection has not yet been configured. SQLite on an ephemeral web service must not be treated as durable production storage.

## Security

- Real credentials must stay outside Git.
- `.env` files are ignored.
- JWT secrets must be long and random in production.
- Production should use `DEBUG=false`.
- File uploads are type- and size-validated.
- Provider/model failures return safe API errors instead of fabricated results.

## Documentation

- [Architecture](docs/architecture.md)
- [Setup](docs/setup.md)
- [API](docs/api.md)
- [ML](docs/ml.md)
- [Deployment](docs/deployment.md)
- [Troubleshooting](docs/troubleshooting.md)

## License

See [LICENSE](LICENSE).
