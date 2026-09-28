<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_user_can_register_and_receive_token(): void
    {
        $response = $this->postJson('/api/v1/auth/register', [
            'name' => 'Test Farmer',
            'email' => 'farmer@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ]);

        $response->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'data' => ['user', 'token'],
            ]);

        $this->assertDatabaseHas('users', [
            'email' => 'farmer@example.com',
        ]);
        $this->assertDatabaseCount('personal_access_tokens', 1);
    }

    public function test_registration_rejects_duplicate_email(): void
    {
        User::factory()->create(['email' => 'farmer@example.com']);

        $this->postJson('/api/v1/auth/register', [
            'name' => 'Another Farmer',
            'email' => 'farmer@example.com',
            'password' => 'password123',
            'password_confirmation' => 'password123',
        ])->assertStatus(422)
          ->assertJsonValidationErrors(['email']);
    }

    public function test_user_can_login_with_registered_password(): void
    {
        $user = User::factory()->create([
            'email' => 'farmer@example.com',
            'password' => Hash::make('password123'),
        ]);

        $response = $this->postJson('/api/v1/auth/login', [
            'email' => 'farmer@example.com',
            'password' => 'password123',
        ]);

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'data' => ['user', 'token'],
            ]);
        $this->assertDatabaseCount('personal_access_tokens', 1);
    }

    public function test_login_rejects_invalid_password(): void
    {
        User::factory()->create([
            'email' => 'farmer@example.com',
            'password' => Hash::make('password123'),
        ]);

        $this->postJson('/api/v1/auth/login', [
            'email' => 'farmer@example.com',
            'password' => 'wrong-password',
        ])->assertStatus(422)
          ->assertJsonValidationErrors(['email']);
    }

    public function test_auth_endpoints_allow_the_github_pages_origin(): void
    {
        config()->set('cors.allowed_origins', [
            'https://jatinkanara21.github.io',
        ]);

        $this->withHeader('Origin', 'https://jatinkanara21.github.io')
            ->options('/api/v1/auth/login')
            ->assertHeader('Access-Control-Allow-Origin', 'https://jatinkanara21.github.io');
    }
}
