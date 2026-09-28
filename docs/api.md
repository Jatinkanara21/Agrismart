# API

Base path: `/api/v1`

## Authentication

- POST `/auth/register`
- POST `/auth/login`
- POST `/auth/logout`
- GET `/user`

## Farming

- GET `/dashboard`
- POST `/crops/recommend`
- POST `/disease/detect`
- POST `/yield/predict`
- GET `/weather`
- POST `/agribot/chat`
- POST `/farming/decision`

Responses use `success`, `message`, and optional `data` / `errors` fields.
