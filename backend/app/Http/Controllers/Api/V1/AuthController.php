<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function register(Request $request): JsonResponse
    {
        $data = $request->validate(['name' => ['required','string','max:100'], 'email' => ['required','email','max:255','unique:users,email'], 'password' => ['required','string','min:8','confirmed']]);
        $user = User::create($data);
        $token = $user->createToken('mobile')->plainTextToken;
        return response()->json(['success'=>true,'message'=>'Registration successful','data'=>['user'=>$user,'token'=>$token]],201);
    }

    public function login(Request $request): JsonResponse
    {
        $data = $request->validate(['email'=>['required','email'],'password'=>['required','string']]);
        $user = User::where('email',$data['email'])->first();
        if (!$user || !Hash::check($data['password'],$user->password)) {
            throw ValidationException::withMessages(['email'=>['The provided credentials are incorrect.']]);
        }
        $user->tokens()->delete();
        return response()->json(['success'=>true,'message'=>'Login successful','data'=>['user'=>$user,'token'=>$user->createToken('mobile')->plainTextToken]]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()?->delete();
        return response()->json(['success'=>true,'message'=>'Logged out successfully']);
    }
}
