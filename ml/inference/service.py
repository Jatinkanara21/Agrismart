"""Model-backed inference boundary.

No production prediction is fabricated here. Integrations should load a real
trained artifact and raise ModelUnavailableError when it is not configured.
"""


class ModelUnavailableError(RuntimeError):
    pass


def require_model(model_path):
    if not model_path:
        raise ModelUnavailableError("No trained model is configured")
    path = __import__("pathlib").Path(model_path)
    if not path.exists():
        raise ModelUnavailableError(f"Configured model does not exist: {path}")
    return path
