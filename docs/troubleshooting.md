# Troubleshooting

## Flutter analyzer failures

Run `flutter pub get`, `dart format .`, and `flutter analyze`. Fix symbols and imports instead of suppressing warnings.

## Laravel startup failures

Run `php artisan optimize:clear` and verify PHP extensions and database credentials.

## ML unavailable

Verify `ML_SERVICE_URL`, model artifacts, Python dependencies, and service health. The application must show an unavailable state rather than inventing a result.
