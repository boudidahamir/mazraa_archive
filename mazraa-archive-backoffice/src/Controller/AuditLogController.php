<?php
// src/Controller/AuditLogController.php

namespace App\Controller;

use App\Service\ApiService;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\HeaderUtils;
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
        // Get all filter parameters
        $page = max(1, $request->query->getInt('page', 1)) - 1; // Convert to 0-based for API
        $search = $request->query->get('search');
        $action = $request->query->get('action');
        $entityType = $request->query->get('entityType');
        $startDate = $request->query->get('startDate');
        $endDate = $request->query->get('endDate');
        $sort = $request->query->get('sort', 'createdAt');
        $direction = $request->query->get('direction', 'desc');
        $export = $request->query->get('export');

        try {
            // Build query parameters
            $params = [
                'page' => $page,
                'size' => $export ? 1000 : 10, // Get all logs for export
                'sort' => $sort . ',' . $direction
            ];

            if ($search) {
                $params['searchTerm'] = $search;
            }
            if ($action) {
                $params['action'] = $action;
            }
            if ($entityType) {
                $params['entityType'] = $entityType;
            }
            if ($startDate) {
                $params['startDate'] = $startDate;
            }
            if ($endDate) {
                $params['endDate'] = $endDate;
            }

            error_log("[AuditLog] Fetching logs with params: " . json_encode($params));

            // Get logs with filters for pagination
            $logs = $this->apiService->get("/audit-logs/search", $params);
            error_log("[AuditLog] Received logs response: " . json_encode($logs));

            // Handle export requests
            if ($export) {
                $logData = $logs['content'] ?? [];
                
                if ($export === 'csv') {
                    return $this->exportCsv($logData);
                } elseif ($export === 'pdf') {
                    return $this->exportPdf($logData);
                }
            }

            // Get all logs to calculate statistics
            $allLogs = $this->apiService->get("/audit-logs/search", [
                'size' => 1000,
                'sort' => 'createdAt,desc'
            ]);
            error_log("[AuditLog] Received all logs response: " . json_encode($allLogs));

            $allLogsList = $allLogs['content'] ?? [];

            // Calculate statistics
            $activeUsers = [];
            $userActionCounts = [];
            $criticalActions = 0;
            $criticalActionTypes = ['DELETE', 'DESTROY', 'ARCHIVE'];

            foreach ($allLogsList as $log) {
                // Count unique active users
                $username = $log['username'] ?? 'unknown';
                if (!in_array($username, $activeUsers)) {
                    $activeUsers[] = $username;
                }

                // Count actions per user
                if (!isset($userActionCounts[$username])) {
                    $userActionCounts[$username] = 0;
                }
                $userActionCounts[$username]++;

                // Count critical actions
                if (in_array(strtoupper($log['action'] ?? ''), $criticalActionTypes)) {
                    $criticalActions++;
                }
            }

            // Find most active user
            $mostActiveUser = ['username' => 'N/A', 'actions' => 0];
            foreach ($userActionCounts as $username => $count) {
                if ($count > $mostActiveUser['actions']) {
                    $mostActiveUser = [
                        'username' => $username,
                        'actions' => $count
                    ];
                }
            }

            return $this->render('audit_log/index.html.twig', [
                'logs' => $logs['content'] ?? [],
                'totalLogs' => $logs['totalElements'] ?? 0,
                'page' => $page + 1, // Convert back to 1-based for template
                'totalPages' => $logs['totalPages'] ?? 1,
                'search' => $search,
                'action' => $action,
                'entityType' => $entityType,
                'startDate' => $startDate,
                'endDate' => $endDate,
                'sort' => $sort,
                'direction' => $direction,
                'activeUsers' => count($activeUsers),
                'mostActiveUser' => $mostActiveUser,
                'criticalActions' => $criticalActions
            ]);
        } catch (\Exception $e) {
            error_log("[AuditLog] Error: " . $e->getMessage());
            error_log("[AuditLog] Stack trace: " . $e->getTraceAsString());
            
            $this->addFlash('error', 'Erreur lors du chargement de l\'historique: ' . $e->getMessage());
            return $this->render('audit_log/index.html.twig', [
                'logs' => [],
                'totalLogs' => 0,
                'page' => 1,
                'totalPages' => 1,
                'search' => $search,
                'action' => $action,
                'entityType' => $entityType,
                'startDate' => $startDate,
                'endDate' => $endDate,
                'sort' => $sort,
                'direction' => $direction,
                'activeUsers' => 0,
                'mostActiveUser' => ['username' => 'N/A', 'actions' => 0],
                'criticalActions' => 0
            ]);
        }
    }

    private function exportCsv(array $logs): Response
    {
        $headers = [
            'Date/Heure',
            'Utilisateur',
            'Action',
            'Type d\'entité',
            'ID Entité',
            'Détails',
            'IP'
        ];

        $rows = [];
        foreach ($logs as $log) {
            $rows[] = [
                $log['createdAt'],
                $log['username'],
                $log['action'],
                $log['entityType'],
                $log['entityId'],
                $log['details'],
                $log['ipAddress']
            ];
        }

        $csv = fopen('php://temp', 'r+');
        fputcsv($csv, $headers);
        foreach ($rows as $row) {
            fputcsv($csv, $row);
        }
        rewind($csv);
        $content = stream_get_contents($csv);
        fclose($csv);

        $response = new Response($content);
        $disposition = HeaderUtils::makeDisposition(
            HeaderUtils::DISPOSITION_ATTACHMENT,
            'audit_log_' . date('Y-m-d_H-i-s') . '.csv'
        );

        $response->headers->set('Content-Type', 'text/csv');
        $response->headers->set('Content-Disposition', $disposition);

        return $response;
    }

    private function exportPdf(array $logs): Response
    {
        // Create PDF content
        $html = $this->renderView('audit_log/pdf.html.twig', [
            'logs' => $logs,
            'date' => new \DateTime()
        ]);

        // Generate PDF using wkhtmltopdf or another PDF library
        // For now, we'll return the HTML as a downloadable file
        $response = new Response($html);
        $disposition = HeaderUtils::makeDisposition(
            HeaderUtils::DISPOSITION_ATTACHMENT,
            'audit_log_' . date('Y-m-d_H-i-s') . '.html'
        );

        $response->headers->set('Content-Type', 'text/html');
        $response->headers->set('Content-Disposition', $disposition);

        return $response;
    }
}