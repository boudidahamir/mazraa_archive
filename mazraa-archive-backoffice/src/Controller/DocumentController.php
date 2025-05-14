<?php

namespace App\Controller;

use App\Entity\Document;
use App\Form\DocumentType;
use App\Service\ApiService;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

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
        $search = $request->query->get('search');
        $type = $request->query->get('type');
        $status = $request->query->get('status');

        $query = array_filter([
            'search' => $search,
            'type' => $type,
            'status' => $status,
        ]);

        try {
            $documents = $this->apiService->get('/api/documents', $query);
            $documentTypes = $this->apiService->get('/api/document-types');
            $documentStatuses = $this->apiService->get('/api/document-statuses');
        } catch (\Exception $e) {
            $this->addFlash('error', 'Une erreur est survenue lors de la récupération des documents.');
            $documents = [];
            $documentTypes = [];
            $documentStatuses = [];
        }

        return $this->render('document/index.html.twig', [
            'documents' => $documents,
            'documentTypes' => $documentTypes,
            'documentStatuses' => $documentStatuses,
            'search' => $search,
            'selectedType' => $type,
            'selectedStatus' => $status,
        ]);
    }

    #[Route('/new', name: 'app_documents_new', methods: ['GET', 'POST'])]
    public function new(Request $request): Response
    {
        $document = new Document();
        $form = $this->createForm(DocumentType::class, $document);
        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            try {
                $this->apiService->post('/api/documents', $document->toApiRequest());
                $this->addFlash('success', 'Le document a été créé avec succès.');
                return $this->redirectToRoute('app_documents_index');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Une erreur est survenue lors de la création du document.');
            }
        }

        return $this->render('document/form.html.twig', [
            'document' => $document,
            'form' => $form->createView(),
        ]);
    }

    #[Route('/{id}', name: 'app_documents_show', methods: ['GET'])]
    public function show(int $id): Response
    {
        try {
            $document = $this->apiService->get('/api/documents/' . $id);
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
            $documentData = $this->apiService->get('/api/documents/' . $id);
            $document = Document::fromApiResponse($documentData);
            
            $form = $this->createForm(DocumentType::class, $document);
            $form->handleRequest($request);

            if ($form->isSubmitted() && $form->isValid()) {
                $this->apiService->put('/api/documents/' . $id, $document->toApiRequest());
                $this->addFlash('success', 'Le document a été mis à jour avec succès.');
                return $this->redirectToRoute('app_documents_index');
            }

            return $this->render('document/form.html.twig', [
                'document' => $document,
                'form' => $form->createView(),
            ]);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Le document n\'a pas été trouvé.');
            return $this->redirectToRoute('app_documents_index');
        }
    }

    #[Route('/{id}', name: 'app_documents_delete', methods: ['POST'])]
    public function delete(Request $request, int $id): Response
    {
        if ($this->isCsrfTokenValid('delete' . $id, $request->request->get('_token'))) {
            try {
                $this->apiService->delete('/api/documents/' . $id);
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
        if ($this->isCsrfTokenValid('archive'.$id, $request->request->get('_token'))) {
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
        if ($this->isCsrfTokenValid('retrieve'.$id, $request->request->get('_token'))) {
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
        if ($this->isCsrfTokenValid('destroy'.$id, $request->request->get('_token'))) {
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
} 