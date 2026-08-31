"""Train AgriSmart plant-disease classifier with all available PlantVillage data."""
from pathlib import Path
import json
from collections import defaultdict
import numpy as np
import tensorflow as tf
from datasets import load_dataset

IMAGE_SIZE=224
BATCH_SIZE=32
MAX_IMAGES=20000
NUM_CLASSES=38
HEAD_EPOCHS=2
FINE_TUNE_EPOCHS=2
OUTPUT=Path("ml/output")
OUTPUT.mkdir(parents=True,exist_ok=True)
AUTOTUNE=tf.data.AUTOTUNE

print("Loading PlantVillage from Hugging Face...")
hf_ds=load_dataset("geraldmc/plantvillage-full",revision="v0.1.0",split="train",streaming=True)

# The source is class-ordered. Collect until every class has enough images,
# then use the largest equal quota available. Never fail because a nominal
# quota is unavailable.
buckets=defaultdict(list)
class_names_by_id={}
for sample in hf_ds:
    label=int(sample["class_idx"])
    if not 0<=label<NUM_CLASSES:
        continue
    class_names_by_id[label]=str(sample["class_label"])
    if len(buckets[label])<MAX_IMAGES//NUM_CLASSES+1:
        buckets[label].append(np.asarray(sample["image"].convert("RGB")))
    if len(buckets)==NUM_CLASSES and all(len(buckets[i])>=MAX_IMAGES//NUM_CLASSES for i in range(NUM_CLASSES)):
        break

missing=sorted(set(range(NUM_CLASSES))-set(buckets))
if missing:
    raise RuntimeError(f"PlantVillage source did not expose all 38 classes; missing: {missing}")

usable=min(len(buckets[i]) for i in range(NUM_CLASSES))
if usable<100:
    raise RuntimeError(f"Only {usable} images are available for the smallest class")
quota=min(usable,MAX_IMAGES//NUM_CLASSES)
print(f"Using {quota} images per class ({quota*NUM_CLASSES} total)")

rng=np.random.default_rng(42)
images=[]; labels=[]
for cid in range(NUM_CLASSES):
    chosen=buckets[cid]
    if len(chosen)>quota:
        chosen=list(rng.choice(chosen,size=quota,replace=False))
    images.extend(chosen); labels.extend([cid]*len(chosen))
images=np.stack(images); labels=np.asarray(labels,dtype=np.int32)

# Stratified 90/10 split.
train_parts=[]; val_parts=[]
for cid in range(NUM_CLASSES):
    idx=rng.permutation(np.flatnonzero(labels==cid))
    cut=max(1,int(len(idx)*.9))
    train_parts.append(idx[:cut]); val_parts.append(idx[cut:])
train_idx=rng.permutation(np.concatenate(train_parts)); val_idx=rng.permutation(np.concatenate(val_parts))

augment=tf.keras.Sequential([
    tf.keras.layers.RandomFlip("horizontal"),
    tf.keras.layers.RandomRotation(.08),
    tf.keras.layers.RandomZoom(.12),
    tf.keras.layers.RandomContrast(.10),
])
preprocess=tf.keras.applications.mobilenet_v2.preprocess_input

def prepare(image,label,training=False):
    image=tf.image.resize(image,(IMAGE_SIZE,IMAGE_SIZE))
    image=tf.cast(image,tf.float32)
    if training: image=augment(image,training=True)
    return preprocess(image),label

train_ds=(tf.data.Dataset.from_tensor_slices((images[train_idx],labels[train_idx]))
          .shuffle(min(4096,len(train_idx)),seed=42)
          .map(lambda x,y:prepare(x,y,True),num_parallel_calls=AUTOTUNE)
          .batch(BATCH_SIZE).prefetch(AUTOTUNE))
val_ds=(tf.data.Dataset.from_tensor_slices((images[val_idx],labels[val_idx]))
        .map(lambda x,y:prepare(x,y),num_parallel_calls=AUTOTUNE)
        .batch(BATCH_SIZE).prefetch(AUTOTUNE))

base=tf.keras.applications.MobileNetV2(input_shape=(IMAGE_SIZE,IMAGE_SIZE,3),include_top=False,weights="imagenet")
base.trainable=False
inputs=tf.keras.Input(shape=(IMAGE_SIZE,IMAGE_SIZE,3))
x=base(inputs,training=False)
x=tf.keras.layers.GlobalAveragePooling2D()(x)
x=tf.keras.layers.Dropout(.2)(x)
outputs=tf.keras.layers.Dense(NUM_CLASSES,activation="softmax")(x)
model=tf.keras.Model(inputs,outputs)
callbacks=[tf.keras.callbacks.EarlyStopping(monitor="val_accuracy",patience=1,restore_best_weights=True),tf.keras.callbacks.ReduceLROnPlateau(monitor="val_loss",factor=.3,patience=1)]
model.compile(optimizer=tf.keras.optimizers.Adam(1e-3),loss="sparse_categorical_crossentropy",metrics=["accuracy"])
model.fit(train_ds,validation_data=val_ds,epochs=HEAD_EPOCHS,callbacks=callbacks)

base.trainable=True
for layer in base.layers[:-30]: layer.trainable=False
model.compile(optimizer=tf.keras.optimizers.Adam(1e-5),loss="sparse_categorical_crossentropy",metrics=["accuracy"])
model.fit(train_ds,validation_data=val_ds,epochs=FINE_TUNE_EPOCHS,callbacks=callbacks)

_,accuracy=model.evaluate(val_ds,verbose=1)
print(f"Validation accuracy: {accuracy:.4f}")
class_names=[class_names_by_id[i] for i in range(NUM_CLASSES)]
converter=tf.lite.TFLiteConverter.from_keras_model(model)
converter.optimizations=[tf.lite.Optimize.DEFAULT]
converter.target_spec.supported_types=[tf.float16]
(OUTPUT/"plant_disease.tflite").write_bytes(converter.convert())
(OUTPUT/"labels.json").write_text(json.dumps(class_names,indent=2),encoding="utf-8")
(OUTPUT/"metrics.json").write_text(json.dumps({"validation_accuracy":float(accuracy),"classes":NUM_CLASSES,"images":int(len(labels)),"images_per_class":int(quota)},indent=2),encoding="utf-8")
print("Generated",OUTPUT/"plant_disease.tflite")
