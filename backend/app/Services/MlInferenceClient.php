<?php

namespace App\Services;

use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\PendingRequest;
use Illuminate\Support\Facades\Http;
use RuntimeException;

class MlInferenceClient
{
    private function client(): PendingRequest
    {
        $url = rtrim((string) config('services.ml.url'), '/');

        if ($url === '') {
            throw new RuntimeException('ML_SERVICE_URL is not configured.');
        }

        return Http::baseUrl($url)
            ->acceptJson()
            ->timeout((int) config('services.ml.timeout', 10))
            ->connectTimeout((int) config('services.ml.connect_timeout', 3));
    }

    /**
     * @throws ConnectionException
     */
    public function predict(string $route, array $payload): array
    {
        $response = $this->client()->post($route, $payload);

        if ($response->status() === 503) {
            throw new RuntimeException(
                (string) ($response->json('message') ?? 'ML model is unavailable.')
            );
        }

        $response->throw();

        $data = $response->json();

        if (!is_array($data)) {
            throw new RuntimeException('ML service returned an invalid response.');
        }

        return $data;
    }
}
