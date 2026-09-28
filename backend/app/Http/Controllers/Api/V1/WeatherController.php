<?php
namespace App\Http\Controllers\Api\V1;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
class WeatherController extends Controller { public function __invoke(Request $request): JsonResponse { return response()->json(['success'=>false,'message'=>'Weather provider is not configured. Set WEATHER_API_KEY and provider configuration.'],503); } }
