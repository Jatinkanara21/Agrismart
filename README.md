# AgriSmart

AgriSmart is a premium Flutter smart-agriculture application designed around a Material 3 design system, modular providers, and API-ready mock services.

## Implemented

- Animated splash and 3-step onboarding
- Login, register, forgot-password flow, and Google-login UI
- Floating bottom navigation: Home, Crops, Scan, Market, Profile
- Premium responsive dashboard with weather, farm stats, quick actions, and insights
- Provider-backed crop CRUD flow with realistic mock data
- Crop progress, health states, and detail navigation
- Disease detection with camera/gallery image selection and mock AI analysis
- 7-day weather forecast, UV, rain, humidity, wind, and prioritized recommendations
- Interactive market price trend charts using `fl_chart`
- Farm management with soil type, pH, moisture, and add-farm UI
- Notification center with unread/read states
- Profile and preferences screens
- Material 3 light/dark themes
- Pull-to-refresh, loading, empty, and retry states

## Architecture

```text
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/
│   ├── theme/
│   ├── routes/
│   └── utils/
├── models/
├── services/
├── providers/
├── widgets/
└── screens/
    ├── splash/
    ├── onboarding/
    ├── auth/
    ├── home/
    ├── crops/
    ├── disease_detection/
    ├── weather/
    ├── market/
    ├── farm/
    ├── notifications/
    └── profile/
```

## Run

```bash
flutter pub get
flutter run
```

The app is intentionally API-key-free. `MockApiService` is the backend seam for replacing dummy data with REST/Firebase/etc. later.
