<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use App\Service\ApiService;

class BaseController extends AbstractController
{
    protected $apiService;

    public function __construct(ApiService $apiService)
    {
        $this->apiService = $apiService;
    }

    protected function renderWithApiData(string $view, array $parameters = [], Response $response = null): Response
    {
        try {
            // Add common data that might be needed across all views
            $parameters['documentTypes'] = [
                'FACTURE' => 'Facture',
                'BON_LIVRAISON' => 'Bon de livraison',
                'ORDRE_PAIEMENT' => 'Ordre de paiement',
                'FICHE_PAIE' => 'Fiche de paie',
            ];

            return $this->render($view, $parameters, $response);
        } catch (\Exception $e) {
            $this->addFlash('error', 'Une erreur est survenue: ' . $e->getMessage());
            return $this->render('error.html.twig', [
                'error' => $e->getMessage(),
            ]);
        }
    }
} 