<?php

namespace App\Controller;

use App\Form\UserType;
use App\Service\ApiService;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\RedirectResponse;

#[Route('/users')]
class UserController extends AbstractController
{ 
    private $apiService;

    public function __construct(ApiService $apiService)
    {
        $this->apiService = $apiService;
    }
    #[Route('/', name: 'user_index')]
    public function index(Request $request): Response
    {
        $searchTerm = $request->query->get('search', '');
        $users = $this->apiService->get('/users/search', ['searchTerm' => $searchTerm]);
        
        return $this->render('user/index.html.twig', [
            'users' => $users['content'] ?? [],
            'search' => $searchTerm,
        ]);
    }

    #[Route('/{id}', name: 'user_show', requirements: ['id' => '\d+'])]
    public function show(int $id): Response
    {
        $user = $this->apiService->get("/users/{$id}");

        return $this->render('user/show.html.twig', [
            'user' => $user,
        ]);
    }

    #[Route('/new', name: 'user_new')]
    public function new(Request $request): Response
    {
        $form = $this->createForm(UserType::class);
        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            try {
                $user = $form->getData();
$plainPassword = $form->get('plainPassword')->getData();

$this->apiService->post('/users', $user->toArray($plainPassword));
                $this->addFlash('success', 'User created successfully.');
                return $this->redirectToRoute('user_index');
            } catch (\Throwable $e) {
                $this->addFlash('danger', 'Error creating user: ' . $e->getMessage());
            }
        }

        return $this->render('user/new.html.twig', [
            'form' => $form->createView(),
        ]);
    }
    #[Route('/{id}/edit', name: 'user_edit', requirements: ['id' => '\d+'])]
    public function edit(Request $request, int $id): Response
    {
        $userArray = $this->apiService->get("/users/{$id}");
        $user = \App\Model\User::fromArray($userArray); // Assumes fromArray method exists in your User model
    
        $form = $this->createForm(UserType::class, $user, ['is_edit' => true]);
        $form->handleRequest($request);
    
        if ($form->isSubmitted() && $form->isValid()) {
            try {
                $plainPassword = $form->get('plainPassword')->getData();
                $this->apiService->put("/users/{$id}", $user->toArray($plainPassword));
                $this->addFlash('success', 'Utilisateur mis à jour avec succès.');
                return $this->redirectToRoute('user_index');
            } catch (\Throwable $e) {
                $this->addFlash('danger', 'Erreur lors de la mise à jour de l\'utilisateur : ' . $e->getMessage());
            }
        }
    
        return $this->render('user/edit.html.twig', [
            'form' => $form->createView(),
            'user' => $user,
        ]);
    }
    

    #[Route('/{id}/delete', name: 'user_delete', methods: ['POST'], requirements: ['id' => '\d+'])]
    public function delete(Request $request, int $id): RedirectResponse
    {
        try {
            $this->apiService->delete("/users/{$id}");
            $this->addFlash('success', 'Utilisateur supprimé avec succès.');
        } catch (\Throwable $e) {
            $this->addFlash('danger', 'Erreur lors de la suppression : ' . $e->getMessage());
        }
    
        return $this->redirectToRoute('user_index');
    }
    
}
