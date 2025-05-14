<?php

namespace App\Controller;

use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Routing\Annotation\Route;

class UserController extends AbstractController
{
    public function index(): Response
    {
        // TODO: Implement API call to fetch users
        throw new \Exception('UserController is not implemented for API-based usage.');
    }
} 