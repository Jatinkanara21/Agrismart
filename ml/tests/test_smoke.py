from pathlib import Path


def test_ml_layout_exists():
    root = Path(__file__).resolve().parents[1]
    assert (root / "inference").is_dir()
    assert (root / "preprocessing").is_dir()
    assert (root / "evaluation").is_dir()
