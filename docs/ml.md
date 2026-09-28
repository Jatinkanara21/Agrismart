# Machine Learning

The ML layer is deliberately model-backed. It must not return fabricated predictions.

## Crop recommendation

Inputs: N, P, K, temperature, humidity, pH, rainfall.

## Disease detection

Input: validated plant image. Output: disease and confidence when a trained model is configured.

## Yield prediction

Inputs: crop, area, weather, soil, and historical features supported by the trained model.

## Evaluation

Classification: accuracy, precision, recall, F1, confusion matrix.

Regression: MAE, MSE, RMSE, R².

Datasets and model artifacts are not committed by default. Document their provenance and retrieval process before production use.
