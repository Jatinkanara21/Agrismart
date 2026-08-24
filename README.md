# AgriSmart

AgriSmart is a premium Flutter smart-agriculture application built with Material 3, Provider, mock backend services, and on-device plant-disease inference.

## AI model

Plant disease analysis is designed around a **MobileNetV2 + PlantVillage** classifier exported to TensorFlow Lite/LiteRT. The Flutter app runs the classifier locally through `flutter_litert`; no Gemini/OpenAI API key is required.

The training pipeline is in `ml/`. It trains on the public PlantVillage dataset and exports:

```text
ml/output/plant_disease.tflite
```

Copy the resulting model to:

```text
assets/models/plant_disease.tflite
```

The runtime lives in `lib/services/local_disease_service.dart`.

## Implemented

- Animated splash and 3-step onboarding
- Login, register, forgot-password flow, and Google-login UI
- Farmer-first Home, My Farm, AI, Market, Profile navigation
- Five AI module entry points: crop recommendation, disease detection, yield prediction, AgriBot, and decision engine
- Premium responsive dashboard with weather, farm stats, quick actions, and insights
- Provider-backed crop CRUD flow with realistic mock data
- Crop progress, health states, and detail navigation
- On-device plant-disease classifier interface
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
├── models/
├── services/
├── providers/
├── widgets/
└── screens/

ml/
├── train.py
├── requirements.txt
└── README.md
```

## Run

```bash
flutter pub get
flutter run
```

No AI API key is required.

## Train the disease model

```bash
python ml/train.py
```

Then copy `ml/output/plant_disease.tflite` to `assets/models/plant_disease.tflite`.

## Important model limitation

PlantVillage is a strong research benchmark but contains many controlled-background leaf images. A model trained only on it should not be treated as a definitive field diagnosis. AgriSmart should eventually be validated with diverse field photographs and agronomist-reviewed data before being used for treatment decisions.

CI note: keep `flutter analyze --no-fatal-infos` clean of compile/analyzer errors before merging production changes.

CI verification branch created to validate the current `main` revision with the dedicated analyze workflow.
