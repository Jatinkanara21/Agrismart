"""Train AgriSmart's offline plant-disease classifier.

Uses the public Hugging Face PlantVillage release instead of TFDS's
Mendeley downloader, which can return HTTP 403 on CI runners.
Exports a MobileNetV2 TFLite model for the Flutter app.
"""
from pathlib import Path
import json
import numpy as np
import tensorflow as tf
from datasets import load_dataset

IMAGE_SIZE = 224
BATCH_SIZE = 32
MAX_IMAGES = 20000
HEAD_EPOCHS = 2
FINE_TUNE_EPOCHS = 2
OUTPUT = Path("ml/output")
OUTPUT.mkdir(parents=True, exist_ok=True)
AUTOTUNE = tf.data.AUTOTUNE

print("Loading PlantVillage from Hugging Face...")
# Streaming avoids downloading the entire dataset before training starts.
hf_ds = load_dataset("geraldmc/plantvillage-full", revision="v0.1.0", split="train", streaming=True)

# Collect a deterministic subset first so train/validation splitting is stable.
samples = []
for sample in hf_ds.take(MAX_IMAGES):
    image = sample["image"].convert("RGB")
    label = int(sample["class_idx"])
    class_name = str(sample["class_label"])
    samples.append((np.asarray(image), label, class_name))

if not samples:
    raise RuntimeError("PlantVillage dataset returned no images")

class_names_by_id = {}
for _, label, class_name in samples:
    class_names_by_id[label] = class_name

num_classes = max(class_names_by_id) + 1
if num_classes != 38:
    raise RuntimeError(f"Expected 38 PlantVillage classes, found {num_classes}")
class_names = [class_names_by_id[i] for i in range(num_classes)]
use_count = len(samples)
print(f"Classes: {num_classes}; using {use_count} images")

images = np.stack([x[0] for x in samples])
labels = np.asarray([x[1] for x in samples], dtype=np.int32)

# Deterministic 90/10 split.
rng = np.random.default_rng(42)
indices = rng.permutation(use_count)
train_count = int(use_count * 0.9)
train_idx, val_idx = indices[:train_count], indices[train_count:]

train_images, train_labels = images[train_idx], labels[train_idx]
val_images, val_labels = images[val_idx], labels[val_idx]

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

train_ds = tf.data.Dataset.from_tensor_slices((train_images, train_labels))
train_ds = (train_ds.shuffle(min(4096, train_count), seed=42)
            .map(lambda x, y: prepare(x, y, True), num_parallel_calls=AUTOTUNE)
            .batch(BATCH_SIZE).prefetch(AUTOTUNE))
val_ds = tf.data.Dataset.from_tensor_slices((val_images, val_labels))
val_ds = (val_ds.map(lambda x, y: prepare(x, y), num_parallel_calls=AUTOTUNE)
          .batch(BATCH_SIZE).prefetch(AUTOTUNE))

base = tf.keras.applications.MobileNetV2(
    input_shape=(IMAGE_SIZE, IMAGE_SIZE, 3),
    include_top=False,
    weights="imagenet",
)
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

model.compile(
    optimizer=tf.keras.optimizers.Adam(1e-3),
    loss="sparse_categorical_crossentropy",
    metrics=["accuracy"],
)
model.fit(train_ds, validation_data=val_ds, epochs=HEAD_EPOCHS, callbacks=callbacks)

base.trainable = True
for layer in base.layers[:-30]:
    layer.trainable = False
model.compile(
    optimizer=tf.keras.optimizers.Adam(1e-5),
    loss="sparse_categorical_crossentropy",
    metrics=["accuracy"],
)
model.fit(train_ds, validation_data=val_ds, epochs=FINE_TUNE_EPOCHS, callbacks=callbacks)

_, accuracy = model.evaluate(val_ds, verbose=1)
print(f"Validation accuracy: {accuracy:.4f}")

converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float16]
tflite_model = converter.convert()
(OUTPUT / "plant_disease.tflite").write_bytes(tflite_model)
(OUTPUT / "labels.json").write_text(json.dumps(class_names, indent=2), encoding="utf-8")
(OUTPUT / "metrics.json").write_text(
    json.dumps({"validation_accuracy": float(accuracy), "classes": num_classes, "images": use_count}, indent=2),
    encoding="utf-8",
)
print("Generated", OUTPUT / "plant_disease.tflite")
