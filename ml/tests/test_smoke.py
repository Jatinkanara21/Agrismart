from pathlib import Path

import pytest

from ml.inference.service import ModelUnavailableError, require_model


def test_ml_layout_exists():
    root = Path(__file__).resolve().parents[1]
    assert (root / "inference").is_dir()
    assert (root / "preprocessing").is_dir()
    assert (root / "evaluation").is_dir()


def test_missing_model_is_rejected():
    with pytest.raises(ModelUnavailableError):
        require_model("")
