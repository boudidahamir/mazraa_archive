<?php

namespace App\Service;

use Symfony\Contracts\HttpClient\HttpClientInterface;
use Symfony\Component\DependencyInjection\ParameterBag\ParameterBagInterface;
use Symfony\Component\HttpFoundation\Session\SessionInterface;
class ApiService
{
    private $httpClient;
    private $baseUrl;
    private $timeout;
    private $session;
    public function __construct(
        HttpClientInterface $httpClient,
        ParameterBagInterface $params,
        SessionInterface $session,
        int $timeout = 30
    ) {
        $this->httpClient = $httpClient;
        $this->baseUrl = $params->get('api_base_url');
        $this->timeout = $timeout;
        $this->session = $session;
    }

    private function getAuthHeaders(): array
    {
        $jwt = $this->session->get('jwt');
        if ($jwt) {
            error_log('[JWT] Sending Authorization header with token');
            return ['Authorization' => 'Bearer ' . $jwt];
        }
        error_log('[JWT] No token in session');
        return [];
    }



    public function get(string $endpoint, array $query = []): array
    {
        try {
            $response = $this->httpClient->request('GET', $this->baseUrl . $endpoint, [
                'query' => $query,
                'timeout' => $this->timeout,
                'headers' => $this->getAuthHeaders(),
            ]);

            return $response->toArray();
        } catch (\Symfony\Contracts\HttpClient\Exception\ClientExceptionInterface $e) {
            error_log("[API GET] Client error: " . $e->getMessage());
            throw $e;
        } catch (\Symfony\Contracts\HttpClient\Exception\TransportExceptionInterface $e) {
            error_log("[API GET] Transport error: " . $e->getMessage());
            throw $e;
        } catch (\Throwable $e) {
            error_log("[API GET] General error: " . $e->getMessage());
            throw $e;
        }
    }


    public function post(string $endpoint, array $data = []): array
    {
        $response = $this->httpClient->request('POST', $this->baseUrl . $endpoint, [
            'json' => $data,
            'timeout' => $this->timeout,
            'headers' => $this->getAuthHeaders(),
        ]);

        return $response->toArray();
    }

    public function put(string $endpoint, array $data = []): array
    {
        $response = $this->httpClient->request('PUT', $this->baseUrl . $endpoint, [
            'json' => $data,
            'timeout' => $this->timeout,
            'headers' => $this->getAuthHeaders(),
        ]);

        return $response->toArray();
    }

    public function delete(string $endpoint): void
{
    $this->httpClient->request('DELETE', $this->baseUrl . $endpoint, [
        'headers' => $this->getAuthHeaders(),
        'timeout' => $this->timeout,
    ]);
}


    public function getDocument(int $id): array
    {
        return $this->get('/documents/' . $id);
    }

    public function getDocuments(): array
    {
        return $this->get('/documents');
    }


    public function updateDocument(int $id, array $data): array
    {
        return $this->put('/documents/' . $id, $data);
    }


    public function login(string $username, string $password): array
    {
        return $this->httpClient->request('POST', $this->baseUrl . '/auth/login', [
            'json' => [
                'username' => $username,
                'password' => $password,
            ],
            'headers' => [
                'Content-Type' => 'application/json',
                'Accept' => 'application/json',
            ],
            'timeout' => $this->timeout,
        ])->toArray();
    }


    public function register(array $data): array
    {
        return $this->post('/auth/register', $data);
    }


    public function searchDocuments(string $term): array
    {
        return $this->get('/documents/search', ['searchTerm' => $term]);
    }

    public function getAllDocumentTypes(): array
    {
        return $this->get('/document-types/search', ['searchTerm' => '']);
    }

    public function getAvailableLocations(): array
    {
        return $this->get('/storage-locations/available');
    }

    public function getLocationByCode(string $code): array
    {
        return $this->get('/storage-locations/code/' . $code);
    }

    public function getUserByUsername(string $username): array
    {
        $headers = $this->getAuthHeaders();
        error_log("[ApiService] GET /users/username/$username with headers: " . json_encode($headers));

        return $this->get('/users/username/' . $username);
    }


    public function searchUsers(string $term): array
    {
        return $this->get('/users/search', ['searchTerm' => $term]);
    }

    public function generateBarcode(string $documentType, int $id): array
    {
        return $this->post('/barcodes/generate', [
            'documentType' => $documentType,
            'id' => $id,
        ]);
    }

    public function getBarcodeImage(string $barcode): string
    {
        $response = $this->httpClient->request('GET', $this->baseUrl . '/barcodes/image/' . $barcode, [
            'timeout' => $this->timeout,
        ]);

        return $response->getContent(); // returns PNG as base64 or binary
    }
    public function syncChanges(array $syncPayload): array
    {
        return $this->post('/sync', $syncPayload);
    }

    public function getPendingSyncs(string $deviceId): array
    {
        return $this->get('/sync/pending/' . $deviceId);
    }

    public function getStorageLocations(): array
    {
        return $this->get('/storage-locations');
    }


}