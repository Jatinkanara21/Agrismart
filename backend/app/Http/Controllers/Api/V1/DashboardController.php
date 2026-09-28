<?php
namespace App\Http\Controllers\Api\V1;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
class DashboardController extends Controller { public function __invoke(Request $request): JsonResponse { return response()->json(['success'=>true,'message'=>'Dashboard retrieved','data'=>['user'=>$request->user()->only(['id','name','email'])]]); } }
