# AgriSmart Offline AI Training

AgriSmart now uses an on-device LiteRT/TFLite classifier instead of Gemini. The training pipeline uses the public PlantVillage dataset, which contains about 54,303 leaf images across 38 crop/disease classes. The TensorFlow Datasets catalog documents the 38-class dataset and its 54,303 training examples. citeturn0search1

## 1. Create a Python environment

Python 3.10–3.12 is recommended for the TensorFlow stack.

```bash
python -m venv .venv
# Windows
.venv\\Scripts\\activate
# macOS/Linux
source .venv/bin/activate
pip install -r ml/requirements.txt
```

## 2. Train

From the repository root:

```bash
python ml/train.py
```

The first run downloads PlantVillage and ImageNet MobileNetV2 weights. No Gemini/OpenAI API key is needed.

## 3. Install the model in Flutter

Copy:

```text
ml/output/plant_disease.tflite
```

to:

```text
assets/models/plant_disease.tflite
```

Then run:

```bash
flutter pub get
flutter run
```

## Model design

- MobileNetV2 transfer learning
- 224x224 RGB input
- Random flip/rotation/zoom/contrast augmentation
- Frozen-backbone training followed by top-layer fine tuning
- 38-class softmax output
- Float16 TFLite export
- On-device inference through `flutter_litert`

## Important accuracy note

PlantVillage images are largely controlled-background leaf images. High benchmark accuracy does not automatically mean the same accuracy on farmer-captured field photos. A production agricultural product should add diverse field images, crop/region-specific validation, and expert review before making treatment decisions. citeturn0search1turn2search7
