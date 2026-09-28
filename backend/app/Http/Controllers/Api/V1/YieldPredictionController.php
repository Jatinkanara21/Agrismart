<?php
namespace App\Http\Controllers\Api\V1;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
class YieldPredictionController extends Controller { public function store(Request $request): JsonResponse { $request->validate(['crop'=>'required|string|max:100','area'=>'required|numeric|min:0']); return response()->json(['success'=>false,'message'=>'Yield prediction model is not configured. Configure a trained ML service before requesting production predictions.'],503); } }
