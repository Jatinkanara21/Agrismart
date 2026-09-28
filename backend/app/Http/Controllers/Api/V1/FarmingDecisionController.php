<?php
namespace App\Http\Controllers\Api\V1;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
class FarmingDecisionController extends Controller { public function store(Request $request): JsonResponse { $request->validate(['crop'=>'nullable|string|max:100','location'=>'nullable|string|max:255','season'=>'nullable|string|max:100']); return response()->json(['success'=>false,'message'=>'Decision engine is not configured with its required data providers/models.'],503); } }
