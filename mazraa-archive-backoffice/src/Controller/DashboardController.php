<?php

namespace App\Controller;

use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class DashboardController extends BaseController
{
    #[Route('/dashboard', name: 'app_dashboard')]
    public function index(): Response
    {
        try {
            // Get summary data from the API
            $documents = $this->apiService->getDocuments();
            $storageLocations = $this->apiService->getStorageLocations();

            // Calculate statistics
            $totalDocuments = count($documents);
            $totalStorageLocations = count($storageLocations);
            $usedStorageLocations = count(array_filter($storageLocations, fn($loc) => $loc['usedSpace'] > 0));
            $availableStorageLocations = $totalStorageLocations - $usedStorageLocations;

            // Group documents by type
            $documentsByType = [];
            foreach ($documents as $document) {
                $type = $document['documentType'];
                if (!isset($documentsByType[$type])) {
                    $documentsByType[$type] = 0;
                }
                $documentsByType[$type]++;
            }

            return $this->renderWithApiData('dashboard/index.html.twig', [
                'totalDocuments' => $totalDocuments,
                'totalStorageLocations' => $totalStorageLocations,
                'usedStorageLocations' => $usedStorageLocations,
                'availableStorageLocations' => $availableStorageLocations,
                'documentsByType' => $documentsByType,
            ]);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur lors du chargement du tableau de bord: ' . $e->getMessage());
            return $this->renderWithApiData('dashboard/index.html.twig', [
                'error' => $e->getMessage(),
            ]);
        }
    }
} 