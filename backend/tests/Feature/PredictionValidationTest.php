<?php

namespace Tests\Feature;

use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Http;
use Tests\TestCase;

class PredictionValidationTest extends TestCase
{
    use RefreshDatabase;

    public function test_prediction_requires_authentication(): void
    {
        $this->postJson('/api/v1/crops/recommend', [])
            ->assertUnauthorized();
    }

    public function test_disease_upload_is_validated(): void
    {
        $user = \App\Models\User::factory()->create();

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/disease/detect', [])
            ->assertStatus(422)
            ->assertJsonValidationErrors(['image']);
    }

    public function test_crop_recommendation_forwards_validated_input_to_ml_service(): void
    {
        config()->set('services.ml.url', 'http://ml.test');

        Http::fake([
            'http://ml.test/v1/crops/recommend' => Http::response([
                'crop' => 'rice',
                'confidence' => 0.91,
            ], 200),
        ]);

        $user = \App\Models\User::factory()->create();

        $response = $this->actingAs($user, 'sanctum')->postJson('/api/v1/crops/recommend', [
            'nitrogen' => 90,
            'phosphorus' => 42,
            'potassium' => 43,
            'temperature' => 24.5,
            'humidity' => 80,
            'ph' => 6.5,
            'rainfall' => 200,
        ]);

        $response->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.crop', 'rice')
            ->assertJsonPath('data.confidence', 0.91);

        Http::assertSent(function ($request) {
            return $request->url() === 'http://ml.test/v1/crops/recommend'
                && $request['nitrogen'] === 90
                && $request['rainfall'] === 200;
        });
    }

    public function test_crop_recommendation_returns_service_unavailable_without_ml_configuration(): void
    {
        config()->set('services.ml.url', null);

        $user = \App\Models\User::factory()->create();

        $this->actingAs($user, 'sanctum')
            ->postJson('/api/v1/crops/recommend', [
                'nitrogen' => 90,
                'phosphorus' => 42,
                'potassium' => 43,
                'temperature' => 24.5,
                'humidity' => 80,
                'ph' => 6.5,
                'rainfall' => 200,
            ])
            ->assertStatus(503)
            ->assertJsonPath('success', false);
    }
}
