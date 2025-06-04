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
        // Get filter parameters
        $page = max(1, $request->query->getInt('page', 1)) - 1; // Convert to 0-based for API
        $search = $request->query->get('search', '');
        $role = $request->query->get('role');
        $status = $request->query->get('status');
        $startDate = $request->query->get('startDate');
        $endDate = $request->query->get('endDate');
        $sort = $request->query->get('sort', 'createdAt');
        $direction = $request->query->get('direction', 'desc');

        try {
            // Build query parameters
            $params = [
                'page' => $page,
                'sort' => $sort . ',' . $direction,
                'searchTerm' => $search
            ];

            if ($role) {
                $params['role'] = $role;
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

            // Get users with filters for pagination
            $users = $this->apiService->get('/users/search', $params);

            // Get all users to calculate statistics
            $allUsers = $this->apiService->get('/users/search', ['size' => 1000]);
            $allUsersList = $allUsers['content'] ?? [];

            // Calculate statistics
            $activeUsers = 0;
            $adminUsers = 0;
            $inactiveUsers = 0;

            foreach ($allUsersList as $user) {
                if ($user['enabled'] ?? true) {
                    $activeUsers++;
                    if (($user['roles'] ?? '') === 'ROLE_ADMIN') {
                        $adminUsers++;
                    }
                } else {
                    $inactiveUsers++;
                }
            }

            return $this->render('user/index.html.twig', [
                'users' => array_map(function($user) {
                    // Convert role to roles array for template compatibility
                    $user['roles'] = [$user['role'] ?? 'ROLE_USER'];
                    return $user;
                }, $users['content'] ?? []),
                'totalUsers' => $users['totalElements'] ?? 0,
                'page' => $page + 1, // Convert back to 1-based for template
                'totalPages' => $users['totalPages'] ?? 1,
                'search' => $search,
                'role' => $role,
                'status' => $status,
                'startDate' => $startDate,
                'endDate' => $endDate,
                'sort' => $sort,
                'direction' => $direction,
                'activeUsers' => $activeUsers,
                'adminUsers' => $adminUsers,
                'inactiveUsers' => $inactiveUsers
            ]);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur lors du chargement des utilisateurs: ' . $e->getMessage());
            return $this->render('user/index.html.twig', [
                'users' => [],
                'totalUsers' => 0,
                'page' => 1,
                'totalPages' => 1,
                'search' => $search,
                'role' => $role,
                'status' => $status,
                'startDate' => $startDate,
                'endDate' => $endDate,
                'sort' => $sort,
                'direction' => $direction,
                'activeUsers' => 0,
                'adminUsers' => 0,
                'inactiveUsers' => 0
            ]);
        }
    }

    #[Route('/{id}', name: 'user_show', requirements: ['id' => '\d+'])]
    public function show(int $id): Response
    {
        try {
            $userArray = $this->apiService->get("/users/{$id}");
            $user = \App\Model\User::fromArray($userArray);

            return $this->render('user/show.html.twig', [
                'user' => $user,
            ]);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur lors du chargement de l\'utilisateur: ' . $e->getMessage());
            return $this->redirectToRoute('user_index');
        }
    }

    #[Route('/new', name: 'user_new')]
    public function new(Request $request): Response
    {
        $user = new \App\Model\User();
        $form = $this->createForm(UserType::class, $user);
        $form->handleRequest($request);

        if ($form->isSubmitted() && $form->isValid()) {
            try {
                $plainPassword = $form->get('plainPassword')->getData();
                if (!$plainPassword) {
                    $this->addFlash('error', 'Le mot de passe est obligatoire.');
                    return $this->render('user/new.html.twig', [
                        'form' => $form->createView(),
                        'title' => 'Nouvel utilisateur'
                    ]);
                }

                $userData = $user->toArray($plainPassword);
                $this->apiService->post('/users', $userData);
                $this->addFlash('success', 'Utilisateur créé avec succès.');
                return $this->redirectToRoute('user_index');
            } catch (\Exception $e) {
                $this->addFlash('error', 'Erreur lors de la création : ' . $e->getMessage());
            }
        }

        return $this->render('user/new.html.twig', [
            'form' => $form->createView(),
            'title' => 'Nouvel utilisateur'
        ]);
    }

    #[Route('/{id}/edit', name: 'user_edit', requirements: ['id' => '\d+'])]
    public function edit(Request $request, int $id): Response
    {
        $userArray = $this->apiService->get("/users/{$id}");
        $user = \App\Model\User::fromArray($userArray);
    
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
    
    #[Route('/{id}/delete', name: 'user_delete', methods: ['POST'])]
    public function delete(Request $request, int $id): Response
    {
        if (!$this->isCsrfTokenValid('delete' . $id, $request->request->get('_token'))) {
            $this->addFlash('error', 'Token CSRF invalide.');
            return $this->redirectToRoute('user_index');
        }

        try {
            $this->apiService->delete("/users/{$id}");
            $this->addFlash('success', 'Utilisateur supprimé avec succès.');
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur lors de la suppression : ' . $e->getMessage());
        }

        return $this->redirectToRoute('user_index');
    }
}
