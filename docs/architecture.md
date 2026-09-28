# Architecture

## Layers

### Mobile
Flutter presents farmer workflows and calls the versioned backend API. Flutter Web receives its production API URL at build time through the `API_BASE_URL` Dart define.

### Backend
Python FastAPI owns authentication, validation, authorization, persistence, orchestration, and stable API responses. SQLAlchemy provides MySQL persistence and JWT bearer tokens provide authentication.

### ML
Python owns preprocessing, model loading, inference, and evaluation. It does not own user authentication or business persistence.

### Request flow

1. Authenticate with FastAPI.
2. Submit validated feature input or image.
3. FastAPI authorizes and validates the request.
4. FastAPI invokes the configured ML/provider service when available.
5. Only an actual model/provider result is returned as a prediction.
6. Missing required models/providers return HTTP 503 instead of fabricated data.

### Deployment

GitHub Pages hosts Flutter Web. The FastAPI backend must run on Python-capable HTTPS hosting with MySQL connectivity.
