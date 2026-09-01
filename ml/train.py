"""Train AgriSmart plant-disease classifier."""
from pathlib import Path
import json
from collections import defaultdict
import numpy as np
import tensorflow as tf
from datasets import load_dataset

IMAGE_SIZE = 224
BATCH_SIZE = 32
MAX_IMAGES = 20000
NUM_CLASSES = 38
HEAD_EPOCHS = 2
FINE_TUNE_EPOCHS = 2
OUTPUT = Path("ml/output")
OUTPUT.mkdir(parents=True, exist_ok=True)
AUTOTUNE = tf.data.AUTOTUNE

print("Loading PlantVillage from Hugging Face...")
hf_ds = load_dataset("geraldmc/plantvillage-full", revision="v0.1.0", split="train", streaming=True)

# PlantVillage is class-ordered. Collect a capped number from each class while
# streaming through the complete source. Do not stop at an arbitrary prefix.
CAP_PER_CLASS = MAX_IMAGES // NUM_CLASSES
buckets = defaultdict(list)
class_names_by_id = {}
for sample in hf_ds:
    cid = int(sample["class_idx"])
    if not 0 <= cid < NUM_CLASSES:
        continue
    class_names_by_id[cid] = str(sample["class_label"])
    if len(buckets[cid]) < CAP_PER_CLASS:
        buckets[cid].append(np.asarray(sample["image"].convert("RGB")))
    # Stop only after every class reaches its cap.
    if len(buckets) == NUM_CLASSES and all(len(buckets[i]) >= CAP_PER_CLASS for i in range(NUM_CLASSES)):
        break

missing = sorted(set(range(NUM_CLASSES)) - set(buckets))
if missing:
    raise RuntimeError(f"PlantVillage source did not expose all 38 classes: {missing}")

# If the source has fewer images in a class, use the common available count.
usable_per_class = min(len(buckets[i]) for i in range(NUM_CLASSES))
if usable_per_class < 100:
    raise RuntimeError(f"Too few images in the smallest class: {usable_per_class}")

rng = np.random.default_rng(42)
images, labels = [], []
for cid in range(NUM_CLASSES):
    chosen = buckets[cid]
    if len(chosen) > usable_per_class:
        chosen = list(rng.choice(chosen, size=usable_per_class, replace=False))
    images.extend(chosen)
    labels.extend([cid] * len(chosen))
images = np.stack(images)
labels = np.asarray(labels, dtype=np.int32)
print(f"Collected {len(labels)} images ({usable_per_class} per class, {NUM_CLASSES} classes)")

# Stratified 90/10 split.
train_idx, val_idx = [], []
for cid in range(NUM_CLASSES):
    idx = rng.permutation(np.flatnonzero(labels == cid))
    cut = max(1, int(len(idx) * 0.9))
    train_idx.extend(idx[:cut])
    val_idx.extend(idx[cut:])
train_idx = rng.permutation(np.asarray(train_idx))
val_idx = rng.permutation(np.asarray(val_idx))

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

train_ds = (tf.data.Dataset.from_tensor_slices((images[train_idx], labels[train_idx]))
            .shuffle(min(4096, len(train_idx)), seed=42)
            .map(lambda x, y: prepare(x, y, True), num_parallel_calls=AUTOTUNE)
            .batch(BATCH_SIZE).prefetch(AUTOTUNE))
val_ds = (tf.data.Dataset.from_tensor_slices((images[val_idx], labels[val_idx]))
          .map(lambda x, y: prepare(x, y), num_parallel_calls=AUTOTUNE)
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
    tf.keras.callbacks.EarlyStopping(monitor="val_accuracy", patience=2, restore_best_weights=True),
    tf.keras.callbacks.ReduceLROnPlateau(monitor="val_loss", factor=0.3, patience=1),
]
model.compile(optimizer=tf.keras.optimizers.Adam(1e-3), loss="sparse_categorical_crossentropy", metrics=["accuracy"])
model.fit(train_ds, validation_data=val_ds, epochs=HEAD_EPOCHS, callbacks=callbacks)

base.trainable = True
for layer in base.layers[:-30]:
    layer.trainable = False
model.compile(optimizer=tf.keras.optimizers.Adam(1e-5), loss="sparse_categorical_crossentropy", metrics=["accuracy"])
model.fit(train_ds, validation_data=val_ds, epochs=FINE_TUNE_EPOCHS, callbacks=callbacks)

loss, accuracy = model.evaluate(val_ds, verbose=1)
print(f"Validation accuracy: {accuracy:.4f}")

class_names = [class_names_by_id[i] for i in range(NUM_CLASSES)]
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float16]
(OUTPUT / "plant_disease.tflite").write_bytes(converter.convert())
(OUTPUT / "labels.json").write_text(json.dumps(class_names, indent=2), encoding="utf-8")
(OUTPUT / "metrics.json").write_text(json.dumps({
    "validation_accuracy": float(accuracy),
    "validation_loss": float(loss),
    "classes": NUM_CLASSES,
    "images": int(len(labels)),
    "images_per_class": int(usable_per_class),
}, indent=2), encoding="utf-8")
print("Training and export completed successfully.")
