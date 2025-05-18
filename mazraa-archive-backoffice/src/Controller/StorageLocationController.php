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
    public function index(): Response
    {
        try {
            $locations = $this->apiService->get('/storage-locations');
        } catch (\Exception $e) {
            $this->addFlash('error', 'Une erreur est survenue lors de la récupération des emplacements.');
            $locations = [];
        }

        return $this->render('storage_location/index.html.twig', [
            'locations' => $locations,
        ]);
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
            $storageLocationData = $this->apiService->get('/storage-locations/' . $id);
            $storageLocation = StorageLocation::fromApiResponse($storageLocationData);

            return $this->render('storage_location/show.html.twig', [
                'storageLocation' => $storageLocation,
            ]);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur lors de la récupération de l\'emplacement: ' . $e->getMessage());
            return $this->redirectToRoute('app_storage_locations_index');
        }
    }
} 