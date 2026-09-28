<?php
namespace App\Http\Controllers\Api\V1;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
class CropRecommendationController extends Controller { public function store(Request $request): JsonResponse { $request->validate(['nitrogen'=>'required|numeric','phosphorus'=>'required|numeric','potassium'=>'required|numeric','temperature'=>'required|numeric','humidity'=>'required|numeric','ph'=>'required|numeric','rainfall'=>'required|numeric']); return response()->json(['success'=>false,'message'=>'Crop recommendation model is not configured. Configure a trained ML service before requesting production predictions.'],503); } }
