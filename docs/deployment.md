# Deployment

Recommended production topology:

Flutter → HTTPS Laravel API → MySQL
                         ↘ ML service
                         ↘ AI/weather providers

Set `APP_ENV=production` and `APP_DEBUG=false`. Use HTTPS, managed secrets, restricted database access, CORS allowlists, backups, logging, and health checks.

Do not deploy a Flutter mobile app to GitHub Pages unless Flutter Web is intentionally supported.
