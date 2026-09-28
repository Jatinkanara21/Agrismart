<?php
namespace Tests\Feature;
use Tests\TestCase;
use Illuminate\Foundation\Testing\RefreshDatabase;
class AuthTest extends TestCase { use RefreshDatabase; public function test_user_can_register(): void { $response=$this->postJson('/api/v1/auth/register',['name'=>'Test Farmer','email'=>'farmer@example.com','password'=>'password123','password_confirmation'=>'password123']); $response->assertCreated()->assertJsonPath('success',true); $this->assertDatabaseHas('users',['email'=>'farmer@example.com']); } }
