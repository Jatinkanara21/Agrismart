"""Train AgriSmart's offline plant-disease classifier.

Uses Hugging Face PlantVillage and explicitly samples every one of its
38 classes. This avoids relying on dataset ordering, which previously caused
the streamed subset to contain only classes 0-15.
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
NUM_CLASSES = 38
OUTPUT = Path("ml/output")
OUTPUT.mkdir(parents=True, exist_ok=True)
AUTOTUNE = tf.data.AUTOTUNE

print("Loading PlantVillage from Hugging Face...")
hf_ds = load_dataset(
    "geraldmc/plantvillage-full",
    revision="v0.1.0",
    split="train",
    streaming=True,
)

# The source is ordered by class. Sample a balanced quota from every class
# instead of taking the first N records. 20,000 / 38 gives 526 per class,
# leaving 12 extra slots distributed deterministically.
base_quota = MAX_IMAGES // NUM_CLASSES
extra = MAX_IMAGES % NUM_CLASSES
quotas = {i: base_quota + (1 if i < extra else 0) for i in range(NUM_CLASSES)}
collected = {i: 0 for i in range(NUM_CLASSES)}
samples = []
class_names_by_id = {}

for sample in hf_ds:
    label = int(sample["class_idx"])
    if label < 0 or label >= NUM_CLASSES:
        continue
    class_name = str(sample["class_label"])
    class_names_by_id[label] = class_name
    if collected[label] >= quotas[label]:
        if all(collected[i] >= quotas[i] for i in range(NUM_CLASSES)):
            break
        continue

    image = sample["image"].convert("RGB")
    samples.append((np.asarray(image), label, class_name))
    collected[label] += 1

    if all(collected[i] >= quotas[i] for i in range(NUM_CLASSES)):
        break

missing = [i for i in range(NUM_CLASSES) if collected[i] == 0]
if missing:
    raise RuntimeError(f"PlantVillage stream did not contain classes: {missing}")
underfilled = {i: n for i, n in collected.items() if n < quotas[i]}
if underfilled:
    raise RuntimeError(f"Could not collect the requested balanced sample: {underfilled}")

class_names = [class_names_by_id[i] for i in range(NUM_CLASSES)]
use_count = len(samples)
print(f"Classes: {NUM_CLASSES}; using {use_count} balanced images")
print(f"Images per class: {collected}")

images = np.stack([x[0] for x in samples])
labels = np.asarray([x[1] for x in samples], dtype=np.int32)

# Deterministic stratified split: 90/10 within each class.
rng = np.random.default_rng(42)
train_parts, val_parts = [], []
for class_id in range(NUM_CLASSES):
    class_indices = np.flatnonzero(labels == class_id)
    class_indices = rng.permutation(class_indices)
    split = int(len(class_indices) * 0.9)
    train_parts.append(class_indices[:split])
    val_parts.append(class_indices[split:])
train_idx = np.concatenate(train_parts)
val_idx = np.concatenate(val_parts)
train_idx = rng.permutation(train_idx)
val_idx = rng.permutation(val_idx)
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
train_ds = (train_ds.shuffle(min(4096, len(train_idx)), seed=42)
            .map(lambda x, y: prepare(x, y, True), num_parallel_calls=AUTOTUNE)
            .batch(BATCH_SIZE).prefetch(AUTOTUNE))
val_ds = tf.data.Dataset.from_tensor_slices((val_images, val_labels))
val_ds = (val_ds.map(lambda x, y: prepare(x, y), num_parallel_calls=AUTOTUNE)
          .batch(BATCH_SIZE).prefetch(AUTOTUNE))

base = tf.keras.applications.MobileNetV2(
    input_shape=(IMAGE_SIZE, IMAGE_SIZE, 3), include_top=False, weights="imagenet"
)
base.trainable = False
inputs = tf.keras.Input(shape=(IMAGE_SIZE, IMAGE_SIZE, 3))
x = base(inputs, training=False)
x = tf.keras.layers.GlobalAveragePooling2D()(x)
x = tf.keras.layers.Dropout(0.2)(x)
outputs = tf.keras.layers.Dense(NUM_CLASSES, activation="softmax")(x)
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
(OUTPUT / "metrics.json").write_text(
    json.dumps({"validation_accuracy": float(accuracy), "classes": NUM_CLASSES, "images": use_count}, indent=2),
    encoding="utf-8",
)
print("Generated", OUTPUT / "plant_disease.tflite")
