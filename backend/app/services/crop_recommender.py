"""Production crop recommendation service for the FastAPI application."""

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

DATASET_PATH = Path(__file__).resolve().parents[2] / "data" / "crop_recommendation.csv"


class CropModelError(RuntimeError):
    pass


@lru_cache(maxsize=1)
def _load_model() -> RandomForestClassifier:
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
    return model


def recommend_crop(values: dict[str, float]) -> dict:
    model = _load_model()
    probabilities = model.predict_proba([[values[name] for name in FEATURES]])[0]
    ranked = sorted(
        zip(model.classes_, probabilities),
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
            "dataset": "crop_recommendation.csv",
            "dataset_rows": len(rows_for_metadata()),
        },
    }


def rows_for_metadata() -> list[dict[str, str]]:
    with DATASET_PATH.open("r", encoding="utf-8", newline="") as handle:
        return list(csv.DictReader(handle))
