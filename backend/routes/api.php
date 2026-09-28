<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\DashboardController;
use App\Http\Controllers\Api\V1\CropRecommendationController;
use App\Http\Controllers\Api\V1\DiseaseDetectionController;
use App\Http\Controllers\Api\V1\YieldPredictionController;
use App\Http\Controllers\Api\V1\WeatherController;
use App\Http\Controllers\Api\V1\AgriBotController;
use App\Http\Controllers\Api\V1\FarmingDecisionController;

Route::prefix('v1')->group(function () {
    Route::prefix('auth')->group(function () {
        Route::post('register', [AuthController::class, 'register']);
        Route::post('login', [AuthController::class, 'login']);
        Route::middleware('auth:sanctum')->post('logout', [AuthController::class, 'logout']);
    });

    Route::middleware('auth:sanctum')->group(function () {
        Route::get('user', fn (\Illuminate\Http\Request $request) => response()->json(['success' => true, 'message' => 'User retrieved', 'data' => $request->user()]));
        Route::get('dashboard', DashboardController::class);
        Route::post('crops/recommend', [CropRecommendationController::class, 'store']);
        Route::post('disease/detect', [DiseaseDetectionController::class, 'store']);
        Route::post('yield/predict', [YieldPredictionController::class, 'store']);
        Route::get('weather', WeatherController::class);
        Route::post('agribot/chat', [AgriBotController::class, 'store']);
        Route::post('farming/decision', [FarmingDecisionController::class, 'store']);
    });
});
