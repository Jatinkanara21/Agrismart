"""Crop recommendation model service.

The model is trained from the committed 2,200-row crop recommendation dataset.
It is a baseline decision-support model, not a guarantee of agronomic outcome.
"""

from functools import lru_cache
from pathlib import Path
import csv

from sklearn.ensemble import RandomForestClassifier

FEATURES = (
    "N",
    "P",
    "K",
    "temperature",
    "humidity",
    "ph",
    "rainfall",
)

DATASET_PATH = (
    Path(__file__).resolve().parents[2] / "data" / "crop_recommendation.csv"
)


class CropModelError(RuntimeError):
    pass


@lru_cache(maxsize=1)
def _load_model() -> tuple[RandomForestClassifier, list[str]]:
    if not DATASET_PATH.exists():
        raise CropModelError(f"Crop dataset is missing: {DATASET_PATH}")

    rows = []
    labels = []
    with DATASET_PATH.open("r", encoding="utf-8", newline="") as handle:
        for row in csv.DictReader(handle):
            rows.append([float(row[name]) for name in FEATURES])
            labels.append(row["label"])

    if len(rows) < 100 or len(set(labels)) < 2:
        raise CropModelError("Crop dataset is too small or has insufficient classes.")

    model = RandomForestClassifier(
        n_estimators=250,
        random_state=42,
        n_jobs=-1,
        class_weight="balanced_subsample",
    )
    model.fit(rows, labels)
    return model, list(model.classes_)


def recommend_crop(values: dict[str, float]) -> dict:
    model, classes = _load_model()
    features = [[values[name] for name in FEATURES]]
    probabilities = model.predict_proba(features)[0]
    ranked = sorted(
        zip(classes, probabilities),
        key=lambda item: item[1],
        reverse=True,
    )[:3]
    return {
        "recommendation": ranked[0][0],
        "confidence": round(float(ranked[0][1]) * 100, 2),
        "alternatives": [
            {"crop": crop, "confidence": round(float(score) * 100, 2)}
            for crop, score in ranked[1:]
        ],
        "model": {
            "type": "RandomForestClassifier",
            "trees": 250,
            "dataset": "Harvestify crop_recommendation.csv",
            "dataset_rows": 2200,
        },
    }
