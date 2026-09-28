# Deployment

## Production architecture

```text
Flutter Web (GitHub Pages)
        |
        | HTTPS /api/v1
        v
Python FastAPI
        |
        +---- MySQL
        +---- Python ML service
        +---- Weather / AI providers
```

GitHub Pages hosts the Flutter Web frontend. It cannot execute FastAPI or provide MySQL. The FastAPI backend needs Python-capable HTTPS hosting.

## Backend requirements

- Python 3.12+
- MySQL 8.x
- HTTPS
- Persistent production `JWT_SECRET`
- Provider environment variables as integrations are enabled
- `backend/Dockerfile` for container-based Python hosting

## Required production environment

```text
APP_NAME=AgriSmart
DEBUG=false
DATABASE_URL=mysql+pymysql://USER:PASSWORD@HOST:3306/DATABASE
JWT_SECRET=YOUR_LONG_RANDOM_SECRET
JWT_ALGORITHM=HS256
JWT_EXPIRE_MINUTES=1440
CORS_ALLOWED_ORIGINS=https://jatinkanara21.github.io
```

Never deploy with the placeholder JWT secret from `.env.example`.

## Health check

Verify `GET /api/v1/health` after deployment. A healthy response reports `status: healthy` and `database: connected`.

## Flutter Web connection

The GitHub Pages workflow requires:

```text
AGRISMART_API_URL=https://YOUR-BACKEND-DOMAIN/api/v1
```

The workflow passes this value to Flutter as `API_BASE_URL`. It intentionally fails before deployment if the variable is missing or is not HTTPS. Do not use `localhost` or `10.0.2.2` in production.

## Database initialization

FastAPI currently creates SQLAlchemy tables at startup with `Base.metadata.create_all`. This is suitable for the current initial schema; a versioned migration system should be added before frequent production schema changes.

## Docker

```bash
cd backend
docker build -t agrismart-api .
docker run --env-file .env -p 8080:8080 agrismart-api
```
