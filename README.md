# AgriSmart

AgriSmart is a premium Flutter smart-agriculture application built with Material 3, Provider, mock backend services, and a real multimodal AI disease-analysis integration.

## AI model

Plant disease analysis uses **Google Gemini 2.5 Flash-Lite** (`gemini-2.5-flash-lite`). The model accepts text plus image input and returns structured JSON containing disease, confidence, symptoms, treatment, and prevention. Gemini's current documentation lists this stable model as a multimodal, cost-efficient model suitable for classification and image understanding.

The AI client lives in `lib/services/gemini_disease_service.dart` and reads the API key from the compile-time `GEMINI_API_KEY` environment value. No key is stored in the repository.

## Implemented

- Animated splash and 3-step onboarding
- Login, register, forgot-password flow, and Google-login UI
- Floating bottom navigation: Home, Crops, Scan, Market, Profile
- Premium responsive dashboard with weather, farm stats, quick actions, and insights
- Provider-backed crop CRUD flow with realistic mock data
- Crop progress, health states, and detail navigation
- Real Gemini multimodal plant-image analysis with confidence, symptoms, treatment, and prevention
- Camera/gallery image selection
- 7-day weather forecast, UV, rain, humidity, wind, and prioritized recommendations
- Interactive market price trend charts using `fl_chart`
- Farm management with soil type, pH, moisture, and add-farm UI
- Notification center with unread/read states
- Profile and preferences screens
- Material 3 light/dark themes
- Pull-to-refresh, loading, empty, and retry states
- GitHub Pages deployment workflow

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
│   ├── mock_api_service.dart
│   └── gemini_disease_service.dart
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

## Local run with AI

```bash
flutter pub get
flutter run --dart-define=GEMINI_API_KEY=YOUR_GEMINI_API_KEY
```

## GitHub Pages deployment

The Pages workflow passes the `GEMINI_API_KEY` GitHub Actions secret into the Flutter web build. Add a repository secret named `GEMINI_API_KEY` before deploying if you want AI analysis enabled on the hosted app. Without the secret, the app still builds and the AI screen clearly reports that Gemini is not configured.

**Security note:** a Flutter web build embeds compile-time values into client-side JavaScript. For a public production application, the recommended architecture is to move the Gemini call behind a secure backend/proxy and keep the API key server-side. The current direct client integration is intended for development/demo deployment.
