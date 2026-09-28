# Setup

## Prerequisites

- Flutter SDK
- PHP and Composer
- MySQL
- Python 3.11+
- Git

## Backend

Copy `.env.example` to `.env`, configure MySQL and service URLs, then run:

```bash
cd backend
composer install
php artisan key:generate
php artisan migrate
php artisan serve
```

## Mobile

```bash
cd mobile
flutter pub get
flutter run
```

Set the API base URL using the application's configuration.

## ML

```bash
cd ml
python -m venv .venv
# Windows: .venv\\Scripts\\activate
# macOS/Linux: source .venv/bin/activate
pip install -r requirements.txt
pytest
```
