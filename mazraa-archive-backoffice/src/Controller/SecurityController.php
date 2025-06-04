<?php

namespace App\Controller;

use App\Service\ApiService;
use Symfony\Bundle\FrameworkBundle\Controller\AbstractController;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\HttpFoundation\Session\SessionInterface;
use Symfony\Component\Routing\Annotation\Route;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\Security\Core\Authentication\Token\UsernamePasswordToken;
use Symfony\Component\Security\Core\Authentication\Token\Storage\TokenStorageInterface;
use Symfony\Component\Security\Core\User\UserProviderInterface;
class SecurityController extends AbstractController
{
    private ApiService $apiService;

    public function __construct(ApiService $apiService)
    {
        $this->apiService = $apiService;
    }
    #[Route('/', name: 'app_login', methods: ['GET', 'POST'])]
    public function login(
        Request $request,
        SessionInterface $session,
        TokenStorageInterface $tokenStorage,
        UserProviderInterface $userProvider
    ): Response {
        $error = null;
        $lastUsername = $session->get('last_username', '');

        if ($request->isMethod('POST')) {
            $username = $request->request->get('_username');
            $password = $request->request->get('_password');
            $session->set('last_username', $username);

            try {
                // Step 1: Login via Spring Boot and get JWT
                $response = $this->apiService->login($username, $password);
                $jwt = $response['token'];
                error_log("[Login] JWT received: " . $jwt);

                // Step 2: Decode JWT and extract roles
                $payload = explode('.', $jwt)[1];
                $decoded = json_decode(base64_decode($payload), true);
                error_log('[Login] Full JWT payload: ' . print_r($decoded, true));
                
                // Check both possible role fields from JWT
                $roles = [];
                if (isset($decoded['roles'])) {
                    $roles = is_array($decoded['roles']) ? $decoded['roles'] : [$decoded['roles']];
                    error_log("[Login] Found roles in 'roles' claim: " . json_encode($roles));
                }
                if (isset($decoded['role'])) {
                    $role = $decoded['role'];
                    error_log("[Login] Found role in 'role' claim: " . $role);
                    $roles = ['ROLE_' . strtoupper($role)];
                }
                error_log("[Login] Final roles array: " . json_encode($roles));

                // Step 3: Store token
                $session->set('jwt', $jwt);
                $session->save();

                // Step 4: Load user and inject roles
                $user = $userProvider->loadUserByIdentifier($username);
                
                // Set the role based on JWT roles
                if (in_array('ROLE_ADMIN', $roles)) {
                    $user->setRole('ADMIN');
                    error_log("[Login] Setting user role to ADMIN");
                } else {
                    $user->setRole('USER');
                    error_log("[Login] Setting user role to USER");
                }

                error_log("[Login] User roles after setting: " . json_encode($user->getRoles()));

                // Step 5: Create Symfony security token
                $token = new UsernamePasswordToken($user, 'main', $user->getRoles());
                $tokenStorage->setToken($token);
                $session->set('_security_main', serialize($token));

                return $this->redirectToRoute('app_dashboard');
            } catch (\Exception $e) {
                error_log("[Login] Exception: " . $e->getMessage());
                $error = 'Invalid credentials or server error.';
            }
        }

        return $this->render('security/login.html.twig', [
            'error' => $error,
            'last_username' => $lastUsername,
        ]);
    }


    #[Route('/logout', name: 'app_logout')]
    public function logout(SessionInterface $session): Response
    {
        $session->remove('jwt');         // Clear the JWT
        $session->remove('_security_main'); // Clear the Symfony security token
        $session->invalidate();
        return $this->redirectToRoute('app_login');
    }
}
