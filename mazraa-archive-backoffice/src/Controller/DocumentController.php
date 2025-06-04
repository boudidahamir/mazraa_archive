<?php

namespace App\Controller;

use App\Model\Document;
use App\Form\DocumentFormType;
use App\Service\ApiService;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\HttpFoundation\HeaderUtils;

#[Route('/documents')]
class DocumentController extends AbstractController
{
    private $apiService;

    public function __construct(ApiService $apiService)
    {
        $this->apiService = $apiService;
    }

    #[Route('/', name: 'app_documents_index', methods: ['GET'])]
    public function index(Request $request): Response
    {
        // Get all filter parameters
        $search = $request->query->get('search');
        $type = $request->query->get('type');
        $status = $request->query->get('status');
        $startDate = $request->query->get('startDate');
        $endDate = $request->query->get('endDate');
        $sort = $request->query->get('sort', 'createdAt');
        $direction = $request->query->get('direction', 'desc');
        $page = max(1, $request->query->getInt('page', 1)) - 1; // Convert to 0-based for API
        $limit = 10; // Items per page

        try {
            // Build query parameters
            $params = [
                'page' => $page,
                'size' => $limit,
                'sort' => $sort . ',' . $direction
            ];

            if ($search) {
                $params['searchTerm'] = $search;
            }
            
            if ($type) {
                $params['documentTypeId'] = $type;
            }

            if ($status) {
                $params['status'] = $status;
            }

            if ($startDate) {
                $params['startDate'] = $startDate;
            }

            if ($endDate) {
                $params['endDate'] = $endDate;
            }

            // Get documents with filters
            $result = $this->apiService->get('/documents/search', $params);
            
            // Get document types for filter dropdown
            $typeData = $this->apiService->get('/document-types/search', ['searchTerm' => '']);

            // Get all documents to calculate statistics
            $allDocs = $this->apiService->get('/documents/search', ['size' => 1000]);
            $allDocuments = $allDocs['content'] ?? [];
            
            // Calculate document statistics
            $activeDocuments = count(array_filter($allDocuments, fn($doc) => $doc['status'] === 'ACTIVE'));
            $archivedDocuments = count(array_filter($allDocuments, fn($doc) => $doc['status'] === 'ARCHIVED'));
            $retrievedDocuments = count(array_filter($allDocuments, fn($doc) => $doc['status'] === 'RETRIEVED'));
            $destroyedDocuments = count(array_filter($allDocuments, fn($doc) => $doc['status'] === 'DESTROYED'));

            // Calculate documents per type
            $documentsPerType = [];
            foreach ($typeData['content'] ?? [] as $type) {
                $typeDocuments = array_filter($allDocuments, fn($doc) => ($doc['documentType']['id'] ?? null) === $type['id']);
                $documentsPerType[$type['name']] = count($typeDocuments);
            }

            // Calculate documents per location
            $locations = $this->apiService->get('/storage-locations');
            $documentsPerLocation = [];
            foreach ($locations ?? [] as $location) {
                $locationDocuments = array_filter($allDocuments, fn($doc) => ($doc['storageLocation']['id'] ?? null) === $location['id']);
                $documentsPerLocation[$location['name']] = count($locationDocuments);
            }

            // Get recent activities (last 10 modified documents)
            usort($allDocuments, fn($a, $b) => strtotime($b['lastModifiedDate'] ?? '') - strtotime($a['lastModifiedDate'] ?? ''));
            $recentActivities = array_slice($allDocuments, 0, 10);

            return $this->render('document/index.html.twig', [
                'documents' => $result['content'] ?? [],
                'totalDocuments' => $result['totalElements'] ?? 0,
                'page' => $page + 1, // Convert back to 1-based for template
                'totalPages' => $result['totalPages'] ?? 1,
                'documentTypes' => $typeData['content'] ?? [],
                'documentStatuses' => ['ACTIVE', 'ARCHIVED', 'RETRIEVED', 'DESTROYED'],
                'search' => $search,
                'selectedType' => $type,
                'selectedStatus' => $status,
                'startDate' => $startDate,
                'endDate' => $endDate,
                'sort' => $sort,
                'direction' => $direction,
                'activeDocuments' => $activeDocuments,
                'archivedDocuments' => $archivedDocuments,
                'retrievedDocuments' => $retrievedDocuments,
                'destroyedDocuments' => $destroyedDocuments,
                'documentsPerType' => $documentsPerType,
                'documentsPerLocation' => $documentsPerLocation,
                'recentActivities' => $recentActivities
            ]);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur lors de la récupération des documents : ' . $e->getMessage());
            return $this->render('document/index.html.twig', [
                'documents' => [],
                'totalDocuments' => 0,
                'page' => 1,
                'totalPages' => 1,
                'documentTypes' => [],
                'documentStatuses' => ['ACTIVE', 'ARCHIVED', 'RETRIEVED', 'DESTROYED'],
                'search' => $search,
                'selectedType' => $type,
                'selectedStatus' => $status,
                'startDate' => $startDate,
                'endDate' => $endDate,
                'sort' => $sort,
                'direction' => $direction,
                'activeDocuments' => 0,
                'archivedDocuments' => 0,
                'retrievedDocuments' => 0,
                'destroyedDocuments' => 0,
                'documentsPerType' => [],
                'documentsPerLocation' => [],
                'recentActivities' => []
            ]);
        }
    }
    
    #[Route('/new', name: 'app_documents_new', methods: ['GET', 'POST'])]
    public function new(Request $request): Response
    {
        $document = new Document();
    
        try {
            // Fetch document types and storage locations from API
            $typeData = $this->apiService->get('/document-types/search', ['searchTerm' => '']);
            $storageData = $this->apiService->get('/storage-locations');
    
            // Format choices for Symfony form
            $docTypeChoices = [];
            foreach ($typeData['content'] ?? [] as $type) {
                $docTypeChoices[$type['name']] = $type['id'];
            }
    
            $storageChoices = [];
            foreach ($storageData ?? [] as $loc) {
                $storageChoices[$loc['name']] = $loc['id'];
            }
    
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur lors du chargement des types ou emplacements : ' . $e->getMessage());
            $docTypeChoices = [];
            $storageChoices = [];
        }
    
        // Create and handle the form
        $form = $this->createForm(DocumentFormType::class, $document, [
            'document_type_choices' => $docTypeChoices,
            'storage_location_choices' => $storageChoices,
        ]);
    
        $form->handleRequest($request);
    
        if ($form->isSubmitted() && $form->isValid()) {
            try {
                $this->apiService->post('/documents', $document->toApiRequest());
                $this->addFlash('success', 'Le document a été créé avec succès.');
                return $this->redirectToRoute('app_documents_index');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur lors de la création du document : ' . $e->getMessage());
            }
        }
    
        return $this->render('document/form.html.twig', [
            'form' => $form->createView(),
            'document' => $document,
        ]);
    }
    


    #[Route('/{id}', name: 'app_documents_show', methods: ['GET'])]
    public function show(int $id): Response
    {
        try {
            $document = $this->apiService->get('/documents/' . $id);
            return $this->render('document/show.html.twig', [
                'document' => $document,
            ]);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Le document n\'a pas été trouvé.');
            return $this->redirectToRoute('app_documents_index');
        }
    }

    #[Route('/{id}/edit', name: 'app_documents_edit', methods: ['GET', 'POST'])]
    public function edit(Request $request, int $id): Response
    {
        try {
            $documentData = $this->apiService->get('/documents/' . $id);
            $document = Document::fromApiResponse($documentData);
    
            // Fetch dropdown data
            $typeData = $this->apiService->get('/document-types/search', ['searchTerm' => '']);
            $locationData = $this->apiService->get('/storage-locations');
    
            // Build choice arrays
            $docTypeChoices = [];
            foreach ($typeData['content'] ?? [] as $type) {
                $docTypeChoices[$type['name']] = $type['id'];
            }
    
            $storageChoices = [];
            foreach ($locationData ?? [] as $loc) {
                $storageChoices[$loc['name']] = $loc['id'];
            }
    
            // Create and handle form
            $form = $this->createForm(DocumentFormType::class, $document, [
                'document_type_choices' => $docTypeChoices,
                'storage_location_choices' => $storageChoices,
            ]);
    
            $form->handleRequest($request);
    
            if ($form->isSubmitted() && $form->isValid()) {
                $this->apiService->put('/documents/' . $id, $document->toApiRequest());
                $this->addFlash('success', 'Le document a été mis à jour avec succès.');
                return $this->redirectToRoute('app_documents_index');
            }
    
            return $this->render('document/form.html.twig', [
                'document' => $document,
                'form' => $form->createView(),
            ]);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Le document n\'a pas été trouvé : ' . $e->getMessage());
            return $this->redirectToRoute('app_documents_index');
        }
    }
    

    #[Route('/{id}', name: 'app_documents_delete', methods: ['POST'])]
    public function delete(Request $request, int $id): Response
    {
        if ($this->isCsrfTokenValid('delete' . $id, $request->request->get('_token'))) {
            try {
                $this->apiService->delete('/documents/' . $id);
                $this->addFlash('success', 'Le document a été supprimé avec succès.');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Une erreur est survenue lors de la suppression du document.');
            }
        }

        return $this->redirectToRoute('app_documents_index');
    }

    #[Route('/{id}/archive', name: 'app_documents_archive', methods: ['POST'])]
    public function archive(Request $request, int $id): Response
    {
        if ($this->isCsrfTokenValid('archive' . $id, $request->request->get('_token'))) {
            try {
                $documentData = $this->apiService->getDocument($id);
                $document = Document::fromApiResponse($documentData);
                $document->setStatus('ARCHIVED');
                $this->apiService->updateDocument($id, $document->toApiRequest());
                $this->addFlash('success', 'Document archivé avec succès.');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur lors de l\'archivage du document: ' . $e->getMessage());
            }
        }

        return $this->redirectToRoute('app_documents_show', ['id' => $id]);
    }

    #[Route('/{id}/retrieve', name: 'app_documents_retrieve', methods: ['POST'])]
    public function retrieve(Request $request, int $id): Response
    {
        if ($this->isCsrfTokenValid('retrieve' . $id, $request->request->get('_token'))) {
            try {
                $documentData = $this->apiService->getDocument($id);
                $document = Document::fromApiResponse($documentData);
                $document->setStatus('RETRIEVED');
                $this->apiService->updateDocument($id, $document->toApiRequest());
                $this->addFlash('success', 'Document retiré avec succès.');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur lors du retrait du document: ' . $e->getMessage());
            }
        }

        return $this->redirectToRoute('app_documents_show', ['id' => $id]);
    }

    #[Route('/{id}/destroy', name: 'app_documents_destroy', methods: ['POST'])]
    public function destroy(Request $request, int $id): Response
    {
        if ($this->isCsrfTokenValid('destroy' . $id, $request->request->get('_token'))) {
            try {
                $documentData = $this->apiService->getDocument($id);
                $document = Document::fromApiResponse($documentData);
                $document->setStatus('DESTROYED');
                $this->apiService->updateDocument($id, $document->toApiRequest());
                $this->addFlash('success', 'Document marqué comme détruit avec succès.');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur lors de la destruction du document: ' . $e->getMessage());
            }
        }

        return $this->redirectToRoute('app_documents_show', ['id' => $id]);
    }

    #[Route('/{id}/export-pdf', name: 'app_documents_export_pdf', methods: ['GET'])]
    public function exportPdf(int $id): Response
    {
        try {
            $document = $this->apiService->get('/documents/' . $id);
            
            // Create PDF content
            $html = $this->renderView('document/pdf.html.twig', [
                'document' => $document,
                'date' => new \DateTime()
            ]);

            // For now, we'll return HTML as a downloadable file
            // Later, you can integrate a proper PDF library like wkhtmltopdf or DomPDF
            $response = new Response($html);
            $disposition = HeaderUtils::makeDisposition(
                HeaderUtils::DISPOSITION_ATTACHMENT,
                'document_' . $document['id'] . '_' . date('Y-m-d_H-i-s') . '.html'
            );

            $response->headers->set('Content-Type', 'text/html');
            $response->headers->set('Content-Disposition', $disposition);

            return $response;
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur lors de l\'export du document: ' . $e->getMessage());
            return $this->redirectToRoute('app_documents_show', ['id' => $id]);
        }
    }

    #[Route('/{id}/print', name: 'app_documents_print', methods: ['GET'])]
    public function print(int $id): Response
    {
        try {
            $document = $this->apiService->get('/documents/' . $id);
            
            return $this->render('document/print.html.twig', [
                'document' => $document,
                'date' => new \DateTime()
            ]);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur lors de l\'impression du document: ' . $e->getMessage());
            return $this->redirectToRoute('app_documents_show', ['id' => $id]);
        }
    }
}