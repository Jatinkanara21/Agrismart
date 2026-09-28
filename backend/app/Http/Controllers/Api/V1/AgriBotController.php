<?php
namespace App\Http\Controllers\Api\V1;
use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;
class AgriBotController extends Controller { public function store(Request $request): JsonResponse { $request->validate(['message'=>'required|string|max:4000']); return response()->json(['success'=>false,'message'=>'AgriBot provider is not configured. Set the backend AI provider before enabling production chat.'],503); } }
