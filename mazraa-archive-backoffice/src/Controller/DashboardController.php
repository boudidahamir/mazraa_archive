<?php

namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use DateTime;

class DashboardController extends BaseController
{
    #[Route('/dashboard', name: 'app_dashboard')]
    public function index(): Response
    {
        try {
            // Get summary data from the API
            $documents = $this->apiService->get('/documents/search', ['size' => 1000])['content'] ?? [];
            $storageLocations = $this->apiService->get('/storage-locations/search', ['size' => 1000])['content'] ?? [];
            $recentActivity = $this->apiService->get('/audit-logs/search', [
                'size' => 10,
                'sort' => 'createdAt,desc'
            ])['content'] ?? [];

            // Calculate document statistics
            $totalDocuments = count($documents);
            $lastWeek = new DateTime('-1 week');
            $recentDocuments = count(array_filter($documents, function($doc) use ($lastWeek) {
                return new DateTime($doc['createdAt']) >= $lastWeek;
            }));

            // Calculate storage statistics
            $totalStorageLocations = count($storageLocations);
            $usedStorageLocations = 0;
            $nearFullLocations = 0;
            $totalCapacity = 0;
            $totalUsed = 0;

            foreach ($storageLocations as $location) {
                $capacity = $location['capacity'] ?? 0;
                $usedSpace = $location['usedSpace'] ?? 0;
                $totalCapacity += $capacity;
                $totalUsed += $usedSpace;

                if ($usedSpace > 0) {
                    $usedStorageLocations++;
                }

                // Consider location near full if it's at 90% capacity or more
                if ($capacity > 0 && ($usedSpace / $capacity) >= 0.9) {
                    $nearFullLocations++;
                }
            }

            $availableStorageLocations = $totalStorageLocations - $usedStorageLocations;
            $storageUtilization = $totalCapacity > 0 ? round(($totalUsed / $totalCapacity) * 100) : 0;
            $availabilityPercentage = $totalStorageLocations > 0 ? 
                round(($availableStorageLocations / $totalStorageLocations) * 100) : 0;

            // Group documents by type
            $documentsByType = [];
            foreach ($documents as $document) {
                $type = $document['documentType']['name'] ?? 'Inconnu';
                $documentsByType[$type] = ($documentsByType[$type] ?? 0) + 1;
            }

            return $this->renderWithApiData('dashboard/index.html.twig', [
                'totalDocuments' => $totalDocuments,
                'recentDocuments' => $recentDocuments,
                'totalStorageLocations' => $totalStorageLocations,
                'usedStorageLocations' => $usedStorageLocations,
                'availableStorageLocations' => $availableStorageLocations,
                'nearFullLocations' => $nearFullLocations,
                'storageUtilization' => $storageUtilization,
                'availabilityPercentage' => $availabilityPercentage,
                'documentsByType' => $documentsByType,
                'recentActivity' => $recentActivity
            ]);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur lors du chargement du tableau de bord: ' . $e->getMessage());
            return $this->renderWithApiData('dashboard/index.html.twig', [
                'totalDocuments' => 0,
                'recentDocuments' => 0,
                'totalStorageLocations' => 0,
                'usedStorageLocations' => 0,
                'availableStorageLocations' => 0,
                'nearFullLocations' => 0,
                'storageUtilization' => 0,
                'availabilityPercentage' => 0,
                'documentsByType' => [],
                'recentActivity' => [],
                'error' => $e->getMessage()
            ]);
        }
    }
}