from ml.inference.crop_recommender import recommend_crop


def test_crop_recommendation_returns_ranked_result():
    result = recommend_crop(
        {
            "N": 90,
            "P": 42,
            "K": 43,
            "temperature": 21,
            "humidity": 82,
            "ph": 6.5,
            "rainfall": 203,
        }
    )

    assert result["recommendation"] == "rice"
    assert 0 <= result["confidence"] <= 100
    assert len(result["alternatives"]) == 2
    assert result["model"]["dataset_rows"] == 2200
