<?php
namespace App\Http\Controllers\Api\V1;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
class DiseaseDetectionController extends Controller { public function store(Request $request): JsonResponse { $request->validate(['image'=>'required|file|image|mimes:jpg,jpeg,png,webp|max:5120']); return response()->json(['success'=>false,'message'=>'Disease detection model is not configured. Configure a trained ML service before requesting production predictions.'],503); } }
