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
    public function index(): Response
    {
        try {
            $types = $this->apiService->get('/document-types/search', ['searchTerm' => '']);
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