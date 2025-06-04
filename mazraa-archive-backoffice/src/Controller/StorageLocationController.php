<?php

namespace App\Controller;

use App\Model\StorageLocation;
use App\Form\StorageLocationType;
use App\Service\ApiService;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

#[Route('/storage-locations')]
class StorageLocationController extends AbstractController
{
    private $apiService;

    public function __construct(ApiService $apiService)
    {
        $this->apiService = $apiService;
    }

    #[Route('/', name: 'app_storage_locations_index', methods: ['GET'])]
    public function index(Request $request): Response
    {
        // Get filter parameters
        $page = max(1, $request->query->getInt('page', 1)) - 1; // Convert to 0-based for API
        $search = $request->query->get('search');
        $capacity = $request->query->get('capacity');
        $sort = $request->query->get('sort', 'name');
        $direction = $request->query->get('direction', 'asc');

        try {
            // Build query parameters for search endpoint
            $params = [
                'page' => $page,
                'size' => 10, // Set a reasonable page size
                'sort' => $sort . ',' . $direction
            ];

            if ($search) {
                $params['searchTerm'] = $search;
            }
            if ($capacity) {
                $params['capacity'] = $capacity;
            }

            // Get locations with filters using the search endpoint
            $locations = $this->apiService->get('/storage-locations/search', $params);

            // Get statistics using a separate call
            $allLocations = $this->apiService->get('/storage-locations');
            $locationsList = $allLocations ?? [];

            // Calculate statistics from all locations
            $availableLocations = 0;
            $usedLocations = 0;
            $nearFullLocations = 0;
            $totalCapacity = 0;
            $usedCapacity = 0;

            foreach ($locationsList as $location) {
                $capacity = $location['capacity'] ?? 0;
                $usedSpace = $location['usedSpace'] ?? 0;
                
                $totalCapacity += $capacity;
                $usedCapacity += $usedSpace;
                
                if ($usedSpace === 0) {
                    $availableLocations++;
                } else {
                    $usedLocations++;
                    // Check for division by zero before calculating utilization
                    if ($capacity > 0 && ($usedSpace / $capacity) >= 0.8) {
                        $nearFullLocations++;
                    }
                }
            }

            // Calculate utilization percentage with zero check
            $capacityUtilization = $totalCapacity > 0 ? round(($usedCapacity / $totalCapacity) * 100, 2) : 0;

            return $this->render('storage_location/index.html.twig', [
                'locations' => $locations['content'] ?? [],
                'totalLocations' => $locations['totalElements'] ?? 0,
                'page' => $page + 1, // Convert back to 1-based for template
                'totalPages' => $locations['totalPages'] ?? 1,
                'search' => $search,
                'capacity' => $capacity,
                'sort' => $sort,
                'direction' => $direction,
                'availableLocations' => $availableLocations,
                'usedLocations' => $usedLocations,
                'nearFullLocations' => $nearFullLocations,
                'totalCapacity' => $totalCapacity,
                'usedCapacity' => $usedCapacity,
                'capacityUtilization' => $capacityUtilization
            ]);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Une erreur est survenue lors de la récupération des emplacements: ' . $e->getMessage());
            return $this->render('storage_location/index.html.twig', [
                'locations' => [],
                'totalLocations' => 0,
                'page' => 1,
                'totalPages' => 1,
                'search' => $search,
                'capacity' => $capacity,
                'sort' => $sort,
                'direction' => $direction,
                'availableLocations' => 0,
                'usedLocations' => 0,
                'nearFullLocations' => 0,
                'totalCapacity' => 0,
                'usedCapacity' => 0,
                'capacityUtilization' => 0
            ]);
        }
    }

    #[Route('/new', name: 'app_storage_locations_new', methods: ['GET', 'POST'])]
    public function new(Request $request): Response
    {
        $storageLocation = new StorageLocation();
        $form = $this->createForm(StorageLocationType::class, $storageLocation);
        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            try {
                $this->apiService->post('/storage-locations', $storageLocation->toApiRequest());
                $this->addFlash('success', 'Emplacement créé avec succès.');
                return $this->redirectToRoute('app_storage_locations_index');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur lors de la création de l\'emplacement: ' . $e->getMessage());
            }
        }

        return $this->render('storage_location/new.html.twig', [
            'storageLocation' => $storageLocation,
            'form' => $form->createView(),
        ]);
    }

    #[Route('/{id}/edit', name: 'app_storage_locations_edit', methods: ['GET', 'POST'])]
    public function edit(Request $request, int $id): Response
    {
        try {
            $storageLocationData = $this->apiService->get('/storage-locations/' . $id);
            $storageLocation = StorageLocation::fromApiResponse($storageLocationData);

            $form = $this->createForm(StorageLocationType::class, $storageLocation);
            $form->handleRequest($request);

            if ($form->isSubmitted() && $form->isValid()) {
                $this->apiService->put('/storage-locations/' . $id, $storageLocation->toApiRequest());
                $this->addFlash('success', 'Emplacement modifié avec succès.');
                return $this->redirectToRoute('app_storage_locations_index');
            }

            return $this->render('storage_location/edit.html.twig', [
                'storageLocation' => $storageLocation,
                'form' => $form->createView(),
            ]);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur lors de la récupération de l\'emplacement: ' . $e->getMessage());
            return $this->redirectToRoute('app_storage_locations_index');
        }
    }

    #[Route('/{id}/delete', name: 'app_storage_locations_delete', methods: ['POST'])]
    public function delete(Request $request, int $id): Response
    {
        if ($this->isCsrfTokenValid('delete'.$id, $request->request->get('_token'))) {
            try {
                $this->apiService->delete('/storage-locations/' . $id);
                $this->addFlash('success', 'Emplacement supprimé avec succès.');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur lors de la suppression de l\'emplacement: ' . $e->getMessage());
            }
        }

        return $this->redirectToRoute('app_storage_locations_index');
    }

    #[Route('/{id}', name: 'app_storage_locations_show', methods: ['GET'])]
    public function show(int $id): Response
    {
        try {
            // Get storage location data
            $storageLocationData = $this->apiService->get('/storage-locations/' . $id);
            $storageLocation = StorageLocation::fromApiResponse($storageLocationData);

            // Get documents for this location
            $documentsData = $this->apiService->get('/documents/search', [
                'storageLocationId' => $id,
                'size' => 1000
            ]);

            return $this->render('storage_location/show.html.twig', [
                'storageLocation' => $storageLocation,
                'documents' => $documentsData['content'] ?? []
            ]);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur lors de la récupération de l\'emplacement: ' . $e->getMessage());
            return $this->redirectToRoute('app_storage_locations_index');
        }
    }
} 