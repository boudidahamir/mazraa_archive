<?php

namespace App\Service;

use Symfony\Contracts\HttpClient\HttpClientInterface;
use Symfony\Component\DependencyInjection\ParameterBag\ParameterBagInterface;

class ApiService
{
    private $httpClient;
    private $baseUrl;
    private $timeout;

    public function __construct(
        HttpClientInterface $httpClient,
        ParameterBagInterface $params,
        int $timeout = 30
    ) {
        $this->httpClient = $httpClient;
        $this->baseUrl = $params->get('api_base_url');
        $this->timeout = $timeout;
    }

    public function get(string $endpoint, array $query = []): array
    {
        $response = $this->httpClient->request('GET', $this->baseUrl . $endpoint, [
            'query' => $query,
            'timeout' => $this->timeout,
        ]);

        return $response->toArray();
    }

    public function post(string $endpoint, array $data = []): array
    {
        $response = $this->httpClient->request('POST', $this->baseUrl . $endpoint, [
            'json' => $data,
            'timeout' => $this->timeout,
        ]);

        return $response->toArray();
    }

    public function put(string $endpoint, array $data = []): array
    {
        $response = $this->httpClient->request('PUT', $this->baseUrl . $endpoint, [
            'json' => $data,
            'timeout' => $this->timeout,
        ]);

        return $response->toArray();
    }

    public function delete(string $endpoint): array
    {
        $response = $this->httpClient->request('DELETE', $this->baseUrl . $endpoint, [
            'timeout' => $this->timeout,
        ]);

        return $response->toArray();
    }

    public function getDocument(int $id): array
    {
        return $this->get('/documents/' . $id);
    }

    public function updateDocument(int $id, array $data): array
    {
        return $this->put('/documents/' . $id, $data);
    }
} 