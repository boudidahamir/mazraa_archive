<?php
// src/Controller/DocumentTypeController.php

namespace App\Controller;

use App\Form\DocumentTypeType;
use App\Model\DocumentType;
use App\Service\ApiService;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\Form\FormFactoryInterface;

#[Route('/document-types')]
class DocumentTypeController extends AbstractController
{
    private ApiService $apiService;
    private FormFactoryInterface $formFactory;

    public function __construct(ApiService $apiService, FormFactoryInterface $formFactory)
    {
        $this->apiService = $apiService;
        $this->formFactory = $formFactory;
    }

    #[Route('/', name: 'document_type_index', methods: ['GET'])]
    public function index(Request $request): Response
    {
        // Get filter parameters
        $page = max(1, $request->query->getInt('page', 1)) - 1; // Convert to 0-based for API
        $search = $request->query->get('search');
        $sort = $request->query->get('sort', 'name');
        $direction = $request->query->get('direction', 'asc');

        try {
            // Build query parameters
            $params = [
                'page' => $page,
                'sort' => $sort . ',' . $direction,
                'searchTerm' => $search ?? ''
            ];

            // Get document types with filters
            $types = $this->apiService->get('/document-types/search', $params);

            // Get all documents to calculate statistics
            $documents = $this->apiService->get('/documents/search', ['size' => 1000]);
            
            // Calculate statistics
            $activeTypes = 0;
            $inactiveTypes = 0;
            $totalDocuments = count($documents['content'] ?? []);
            $documentsPerType = [];
            $mostUsedType = ['name' => 'N/A', 'count' => 0];

            foreach ($types['content'] ?? [] as $type) {
                if ($type['active'] ?? true) {
                    $activeTypes++;
                } else {
                    $inactiveTypes++;
                }
                
                // Count documents for each type
                $typeDocuments = array_filter(
                    $documents['content'] ?? [], 
                    fn($doc) => ($doc['documentType']['id'] ?? null) === $type['id']
                );
                $count = count($typeDocuments);
                $documentsPerType[$type['name']] = $count;

                // Update most used type if this type has more documents
                if ($count > $mostUsedType['count']) {
                    $mostUsedType = [
                        'name' => $type['name'],
                        'count' => $count
                    ];
                }
            }

            return $this->render('document_type/index.html.twig', [
                'types' => $types['content'] ?? [],
                'totalTypes' => $types['totalElements'] ?? 0,
                'page' => $page + 1, // Convert back to 1-based for template
                'totalPages' => $types['totalPages'] ?? 1,
                'search' => $search,
                'sort' => $sort,
                'direction' => $direction,
                'activeTypes' => $activeTypes,
                'inactiveTypes' => $inactiveTypes,
                'totalDocuments' => $totalDocuments,
                'documentsPerType' => $documentsPerType,
                'mostUsedType' => $mostUsedType
            ]);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur lors de la récupération des types de documents: ' . $e->getMessage());
            return $this->render('document_type/index.html.twig', [
                'types' => [],
                'totalTypes' => 0,
                'page' => 1,
                'totalPages' => 1,
                'search' => $search,
                'sort' => $sort,
                'direction' => $direction,
                'activeTypes' => 0,
                'inactiveTypes' => 0,
                'totalDocuments' => 0,
                'documentsPerType' => [],
                'mostUsedType' => ['name' => 'N/A', 'count' => 0]
            ]);
        }
    }

    #[Route('/new', name: 'document_type_new', methods: ['GET', 'POST'])]
    public function new(Request $request): Response
    {
        $type = new DocumentType();
        $form = $this->formFactory->create(DocumentTypeType::class, $type);
        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            try {
                $this->apiService->post('/document-types', $type->toApiRequest());
                $this->addFlash('success', 'Type de document ajouté avec succès.');
                return $this->redirectToRoute('document_type_index');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur lors de la création du type.');
            }
        }

        return $this->render('document_type/form.html.twig', [
            'form' => $form->createView(),
        ]);
    }

    #[Route('/{id}/edit', name: 'document_type_edit', methods: ['GET', 'POST'])]
    public function edit(Request $request, int $id): Response
    {
        try {
            $data = $this->apiService->get("/document-types/$id");
            $type = DocumentType::fromApiResponse($data);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Type introuvable.');
            return $this->redirectToRoute('document_type_index');
        }

        $form = $this->createForm(DocumentTypeType::class, $type);
        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            try {
                $this->apiService->put("/document-types/$id", $type->toApiRequest());
                $this->addFlash('success', 'Type mis à jour avec succès.');
                return $this->redirectToRoute('document_type_index');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur lors de la mise à jour.');
            }
        }

        return $this->render('document_type/form.html.twig', [
            'form' => $form->createView(),
        ]);
    }

    #[Route('/{id}', name: 'document_type_delete', methods: ['POST'])]
    public function delete(Request $request, int $id): Response
    {
        if ($this->isCsrfTokenValid('delete' . $id, $request->request->get('_token'))) {
            try {
                $this->apiService->delete("/document-types/$id");
                $this->addFlash('success', 'Type supprimé avec succès.');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur lors de la suppression.');
            }
        }
        return $this->redirectToRoute('document_type_index');
    }
}