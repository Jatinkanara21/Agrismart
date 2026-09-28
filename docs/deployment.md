# Deployment

## Production architecture

```
Flutter Web (GitHub Pages)
        |
        | HTTPS /api/v1
        v
Laravel 13 API
        |
        +---- MySQL
        |
        +---- Python ML service
        |
        +---- Weather / AI providers
```

GitHub Pages can host the Flutter Web frontend, but it cannot execute PHP/Laravel or provide MySQL. The Laravel backend therefore needs a PHP-capable hosting service.

## Backend requirements

- PHP 8.3+
- MySQL 8.x
- Composer 2
- HTTPS
- A persistent `APP_KEY`
- Writable `storage/` and `bootstrap/cache/`
- Environment variables configured by the hosting provider

The repository includes `backend/Dockerfile` for container-based PHP hosting.

## Required production environment

Set these values in the backend hosting service; never commit production secrets:

```text
APP_ENV=production
APP_DEBUG=false
APP_URL=https://YOUR-BACKEND-DOMAIN
APP_KEY=YOUR_GENERATED_LARAVEL_KEY

DB_CONNECTION=mysql
DB_HOST=YOUR_DB_HOST
DB_PORT=3306
DB_DATABASE=YOUR_DB_NAME
DB_USERNAME=YOUR_DB_USER
DB_PASSWORD=YOUR_DB_PASSWORD

CORS_ALLOWED_ORIGINS=https://jatinkanara21.github.io

ML_SERVICE_URL=https://YOUR-ML-SERVICE
ML_SERVICE_TIMEOUT=10
ML_SERVICE_CONNECT_TIMEOUT=3

WEATHER_API_KEY=...
AI_API_KEY=...
```

Replace the placeholders with values from the actual hosting provider.

## Health check

After deployment, verify:

```text
GET /api/v1/health
```

A healthy response reports `status: healthy` and `database: connected`. If the database is unavailable, the endpoint returns HTTP 503.

## Flutter Web connection

The GitHub Pages workflow expects the repository Actions variable:

```text
AGRISMART_API_URL=https://YOUR-BACKEND-DOMAIN/api
```

The Flutter web build uses that value as `API_BASE_URL`. Do not point production at `localhost` or `10.0.2.2`; those addresses are for local development/emulators only.

## Database migrations

The container startup runs `php artisan migrate --force` and `php artisan config:cache`. The hosting environment must provide valid production database credentials before the application starts.

## Local development

```bash
cd backend
cp .env.example .env
composer install
php artisan key:generate
php artisan migrate
php artisan serve
```

Local API health check: `http://127.0.0.1:8000/api/v1/health`
