<?php
// src/Controller/DocumentTypeController.php

namespace App\Controller;

use App\Form\DocumentTypeType as DocumentTypeForm;
use App\Model\DocumentType;
use App\Service\ApiService;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

#[Route('/document-types')]
class DocumentTypeController extends AbstractController
{
    public function __construct(private readonly ApiService $apiService) {}

    #[Route('/', name: 'document_type_index', methods: ['GET'])]
    public function index(): Response
    {
        try {
            $types = $this->apiService->get('/api/document-types/search', ['searchTerm' => '']);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur lors de la récupération des types de documents.');
            $types = ['content' => []];
        }

        return $this->render('document_type/index.html.twig', [
            'types' => $types['content'] ?? [],
        ]);
    }

    #[Route('/new', name: 'document_type_new', methods: ['GET', 'POST'])]
    public function new(Request $request): Response
    {
        $type = new DocumentType();
        $form = $this->createForm(DocumentTypeForm::class, $type);
        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            try {
                $this->apiService->post('/api/document-types', $type->toApiRequest());
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
            $data = $this->apiService->get("/api/document-types/$id");
            $type = DocumentType::fromApiResponse($data);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Type introuvable.');
            return $this->redirectToRoute('document_type_index');
        }

        $form = $this->createForm(DocumentTypeForm::class, $type);
        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            try {
                $this->apiService->put("/api/document-types/$id", $type->toApiRequest());
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
                $this->apiService->delete("/api/document-types/$id");
                $this->addFlash('success', 'Type supprimé avec succès.');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur lors de la suppression.');
            }
        }
        return $this->redirectToRoute('document_type_index');
    }
}