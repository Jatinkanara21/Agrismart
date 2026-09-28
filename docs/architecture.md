# Architecture

## Layers

### Mobile
Flutter presents farmer workflows and calls the versioned backend API. Secrets remain outside the application binary.

### Backend
Laravel owns authentication, validation, authorization, persistence, orchestration, and safe API responses.

### ML
Python owns preprocessing, model loading, inference, and evaluation. It does not own user authentication or business persistence.

### Database
MySQL stores users, farmer profiles, prediction history, weather records, conversations, and decision records.

## Request flow

1. Authenticate with Laravel.
2. Submit validated feature input or image.
3. Laravel authorizes and persists relevant request metadata.
4. Laravel invokes the configured ML/provider service.
5. Only an actual model/provider result is returned as a prediction.
6. Errors are returned in a stable JSON envelope.
