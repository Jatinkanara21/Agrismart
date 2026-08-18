"""Train AgriSmart's offline plant-disease classifier.

Uses TensorFlow Datasets PlantVillage and exports a MobileNetV2 TFLite model.
No Gemini/OpenAI API key is required.

CI uses a deterministic 20k-image subset so the model can be produced on a
GitHub Actions CPU runner. Increase MAX_IMAGES/EPOCHS for larger training.
"""
from pathlib import Path
import json
import tensorflow as tf
import tensorflow_datasets as tfds

IMAGE_SIZE = 224
BATCH_SIZE = 32
MAX_IMAGES = 20000
HEAD_EPOCHS = 2
FINE_TUNE_EPOCHS = 2
OUTPUT = Path("ml/output")
OUTPUT.mkdir(parents=True, exist_ok=True)
AUTOTUNE = tf.data.AUTOTUNE

print("Loading PlantVillage from TensorFlow Datasets...")
(ds, info) = tfds.load("plant_village", split="train", as_supervised=True, with_info=True)
num_classes = info.features["label"].num_classes
class_names = info.features["label"].names
available = info.splits["train"].num_examples
use_count = min(MAX_IMAGES, available)
print(f"Classes: {num_classes}; using {use_count}/{available} images")

ds = ds.take(use_count)
train_count = int(use_count * 0.9)
train_ds = ds.take(train_count)
val_ds = ds.skip(train_count)

augment = tf.keras.Sequential([
    tf.keras.layers.RandomFlip("horizontal"),
    tf.keras.layers.RandomRotation(0.08),
    tf.keras.layers.RandomZoom(0.12),
    tf.keras.layers.RandomContrast(0.10),
])
preprocess = tf.keras.applications.mobilenet_v2.preprocess_input

def prepare(image, label, training=False):
    image = tf.image.resize(image, (IMAGE_SIZE, IMAGE_SIZE))
    image = tf.cast(image, tf.float32)
    if training:
        image = augment(image, training=True)
    return preprocess(image), label

train_ds = (train_ds.shuffle(4096, seed=42)
            .map(lambda x, y: prepare(x, y, True), num_parallel_calls=AUTOTUNE)
            .batch(BATCH_SIZE).prefetch(AUTOTUNE))
val_ds = (val_ds.map(lambda x, y: prepare(x, y), num_parallel_calls=AUTOTUNE)
          .batch(BATCH_SIZE).prefetch(AUTOTUNE))

base = tf.keras.applications.MobileNetV2(input_shape=(IMAGE_SIZE, IMAGE_SIZE, 3), include_top=False, weights="imagenet")
base.trainable = False
inputs = tf.keras.Input(shape=(IMAGE_SIZE, IMAGE_SIZE, 3))
x = base(inputs, training=False)
x = tf.keras.layers.GlobalAveragePooling2D()(x)
x = tf.keras.layers.Dropout(0.2)(x)
outputs = tf.keras.layers.Dense(num_classes, activation="softmax")(x)
model = tf.keras.Model(inputs, outputs)

callbacks = [
    tf.keras.callbacks.EarlyStopping(monitor="val_accuracy", patience=1, restore_best_weights=True),
    tf.keras.callbacks.ReduceLROnPlateau(monitor="val_loss", factor=0.3, patience=1),
]

model.compile(optimizer=tf.keras.optimizers.Adam(1e-3), loss="sparse_categorical_crossentropy", metrics=["accuracy"])
model.fit(train_ds, validation_data=val_ds, epochs=HEAD_EPOCHS, callbacks=callbacks)

base.trainable = True
for layer in base.layers[:-30]:
    layer.trainable = False
model.compile(optimizer=tf.keras.optimizers.Adam(1e-5), loss="sparse_categorical_crossentropy", metrics=["accuracy"])
model.fit(train_ds, validation_data=val_ds, epochs=FINE_TUNE_EPOCHS, callbacks=callbacks)

_, accuracy = model.evaluate(val_ds, verbose=1)
print(f"Validation accuracy: {accuracy:.4f}")

converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float16]
tflite_model = converter.convert()
(OUTPUT / "plant_disease.tflite").write_bytes(tflite_model)
(OUTPUT / "labels.json").write_text(json.dumps(class_names, indent=2), encoding="utf-8")
(OUTPUT / "metrics.json").write_text(json.dumps({"validation_accuracy": float(accuracy), "classes": num_classes, "images": use_count}, indent=2), encoding="utf-8")
print("Generated", OUTPUT / "plant_disease.tflite")
