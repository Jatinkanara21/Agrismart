"""Train AgriSmart's offline plant-disease classifier.

Dataset: TensorFlow Datasets PlantVillage (38 classes).
Model: MobileNetV2 transfer learning, 224x224 RGB, softmax output.
Output: ml/output/plant_disease.tflite + labels.txt

This script must be run on a machine with internet access for the first
TFDS/model-weight download. It does not require any Gemini/OpenAI API key.
"""

from pathlib import Path
import json
import tensorflow as tf
import tensorflow_datasets as tfds

IMAGE_SIZE = 224
BATCH_SIZE = 32
HEAD_EPOCHS = 5
FINE_TUNE_EPOCHS = 8
OUTPUT = Path("output")
OUTPUT.mkdir(parents=True, exist_ok=True)

AUTOTUNE = tf.data.AUTOTUNE

print("Loading PlantVillage from TensorFlow Datasets...")
(ds, info) = tfds.load(
    "plant_village",
    split="train",
    as_supervised=True,
    with_info=True,
)

num_classes = info.features["label"].num_classes
class_names = info.features["label"].names
print(f"Classes: {num_classes}")
print("Images:", info.splits["train"].num_examples)

# Deterministic 90/10 split for a reproducible baseline. For a research-grade
# evaluation, use leaf-grouped splits from the original PlantVillage metadata.
train_count = int(info.splits["train"].num_examples * 0.9)
train_ds = ds.take(train_count)
val_ds = ds.skip(train_count)

augment = tf.keras.Sequential([
    tf.keras.layers.RandomFlip("horizontal"),
    tf.keras.layers.RandomRotation(0.08),
    tf.keras.layers.RandomZoom(0.12),
    tf.keras.layers.RandomContrast(0.10),
], name="augmentation")

preprocess = tf.keras.applications.mobilenet_v2.preprocess_input

def prepare(image, label, training=False):
    image = tf.image.resize(image, (IMAGE_SIZE, IMAGE_SIZE))
    image = tf.cast(image, tf.float32)
    if training:
        image = augment(image, training=True)
    image = preprocess(image)
    return image, label

train_ds = (
    train_ds.shuffle(4096, seed=42, reshuffle_each_iteration=True)
    .map(lambda x, y: prepare(x, y, True), num_parallel_calls=AUTOTUNE)
    .batch(BATCH_SIZE)
    .prefetch(AUTOTUNE)
)
val_ds = (
    val_ds.map(lambda x, y: prepare(x, y, False), num_parallel_calls=AUTOTUNE)
    .batch(BATCH_SIZE)
    .prefetch(AUTOTUNE)
)

base = tf.keras.applications.MobileNetV2(
    input_shape=(IMAGE_SIZE, IMAGE_SIZE, 3),
    include_top=False,
    weights="imagenet",
)
base.trainable = False

inputs = tf.keras.Input(shape=(IMAGE_SIZE, IMAGE_SIZE, 3), name="image")
x = base(inputs, training=False)
x = tf.keras.layers.GlobalAveragePooling2D()(x)
x = tf.keras.layers.Dropout(0.2)(x)
outputs = tf.keras.layers.Dense(num_classes, activation="softmax", name="probabilities")(x)
model = tf.keras.Model(inputs, outputs)

model.compile(
    optimizer=tf.keras.optimizers.Adam(1e-3),
    loss="sparse_categorical_crossentropy",
    metrics=["accuracy"],
)

callbacks = [
    tf.keras.callbacks.EarlyStopping(monitor="val_accuracy", patience=3, restore_best_weights=True),
    tf.keras.callbacks.ReduceLROnPlateau(monitor="val_loss", factor=0.3, patience=2),
]

print("Training classification head...")
model.fit(train_ds, validation_data=val_ds, epochs=HEAD_EPOCHS, callbacks=callbacks)

print("Fine-tuning the top MobileNetV2 layers...")
base.trainable = True
for layer in base.layers[:-30]:
    layer.trainable = False

model.compile(
    optimizer=tf.keras.optimizers.Adam(1e-5),
    loss="sparse_categorical_crossentropy",
    metrics=["accuracy"],
)
model.fit(train_ds, validation_data=val_ds, epochs=FINE_TUNE_EPOCHS, callbacks=callbacks)

loss, accuracy = model.evaluate(val_ds, verbose=1)
print(f"Validation accuracy: {accuracy:.4f}")

# Float16 quantization keeps accuracy close to float while shrinking the file.
converter = tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations = [tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types = [tf.float16]
tflite_model = converter.convert()
(OUTPUT / "plant_disease.tflite").write_bytes(tflite_model)

(OUTPUT / "labels.json").write_text(json.dumps(class_names, indent=2), encoding="utf-8")
(OUTPUT / "metrics.json").write_text(
    json.dumps({"validation_accuracy": float(accuracy), "classes": num_classes}, indent=2),
    encoding="utf-8",
)

print("Generated:")
print(OUTPUT / "plant_disease.tflite")
print(OUTPUT / "labels.json")
print(OUTPUT / "metrics.json")
