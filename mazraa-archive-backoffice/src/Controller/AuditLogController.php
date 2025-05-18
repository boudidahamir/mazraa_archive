<?php
// src/Controller/AuditLogController.php

namespace App\Controller;

use App\Service\ApiService;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

#[Route('/audit-logs')]
class AuditLogController extends AbstractController
{
    private ApiService $apiService;

    public function __construct(ApiService $apiService)
    {
        $this->apiService = $apiService;
    }

    #[Route('/', name: 'audit_log_index', methods: ['GET'])]
    public function index(Request $request): Response
    {
        $page = $request->query->get('page', 0);

        try {
            $logs = $this->apiService->get("/audit-logs", ['page' => $page]);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Erreur lors du chargement de l\'historique.');
            $logs = ['content' => [], 'totalPages' => 1];
        }

        return $this->render('audit_log/index.html.twig', [
            'logs' => $logs['content'] ?? [],
            'page' => $page,
            'totalPages' => $logs['totalPages'] ?? 1,
        ]);
    }
}