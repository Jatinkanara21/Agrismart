# AgriSmart Offline Disease Model

Place the trained TensorFlow Lite model here as:

```text
assets/models/plant_disease.tflite
```

The Flutter app expects a **MobileNetV2-style 224x224 RGB classifier with 38 PlantVillage classes** and softmax output in the label order used by `LocalDiseaseService`.

The model is intentionally not checked into this text-only repository until it is actually trained and evaluated. Run the training pipeline in `ml/` to generate it.
