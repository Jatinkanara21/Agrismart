# Setup

## Prerequisites

- Flutter SDK
- Python 3.12+
- MySQL 8.x
- Git

## Backend

```bash
cd backend
python -m venv .venv
# Windows: .venv\\Scripts\\activate
# macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
```

Copy `backend/.env.example` to `.env`, configure MySQL and the JWT secret, then run:

```bash
uvicorn main:app --reload --port 8000
```

Health check: `http://127.0.0.1:8000/api/v1/health`

## Mobile

```bash
cd mobile
flutter pub get
flutter run
```

Android emulator development uses `http://10.0.2.2:8000/api/v1` by default. Flutter Web receives `API_BASE_URL` at build time.

## ML

```bash
cd ml
python -m venv .venv
pip install -r requirements.txt
pytest
```
