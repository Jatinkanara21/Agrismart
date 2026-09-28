<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Services\MlInferenceClient;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use RuntimeException;

class CropRecommendationController extends Controller
{
    public function __construct(private readonly MlInferenceClient $ml)
    {
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'nitrogen' => 'required|numeric',
            'phosphorus' => 'required|numeric',
            'potassium' => 'required|numeric',
            'temperature' => 'required|numeric',
            'humidity' => 'required|numeric',
            'ph' => 'required|numeric',
            'rainfall' => 'required|numeric',
        ]);

        try {
            $result = $this->ml->predict('/v1/crops/recommend', $validated);

            return response()->json([
                'success' => true,
                'data' => $result,
            ]);
        } catch (RuntimeException $exception) {
            return response()->json([
                'success' => false,
                'message' => $exception->getMessage(),
            ], 503);
        }
    }
}
