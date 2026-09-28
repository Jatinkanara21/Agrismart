<?php
namespace Tests\Feature;
use Tests\TestCase;use Illuminate\Foundation\Testing\RefreshDatabase;
class PredictionValidationTest extends TestCase { use RefreshDatabase; public function test_prediction_requires_authentication(): void { $this->postJson('/api/v1/crops/recommend',[])->assertUnauthorized(); } public function test_disease_upload_is_validated(): void { $user=\App\Models\User::factory()->create(); $this->actingAs($user,'sanctum')->postJson('/api/v1/disease/detect',[])->assertStatus(422)->assertJsonValidationErrors(['image']); } }
