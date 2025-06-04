<?php
namespace App\Security;
use Lcobucci\JWT\Configuration;
use Symfony\Component\Security\Http\Authenticator\AbstractAuthenticator;
use Symfony\Component\Security\Http\Authenticator\Passport\Badge\UserBadge;
use Symfony\Component\Security\Http\Authenticator\Passport\SelfValidatingPassport;
use Symfony\Component\Security\Core\Exception\AuthenticationException;
use Symfony\Component\HttpFoundation\Request;
use Symfony\Component\Security\Core\User\UserProviderInterface;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpFoundation\Session\SessionInterface;
use Lcobucci\JWT\Signer\Hmac\Sha256;
use Lcobucci\JWT\Signer\Key\InMemory;
use Lcobucci\JWT\Token\Plain;

class JwtAuthenticator extends AbstractAuthenticator
{
    private UserProviderInterface $userProvider;
    private SessionInterface $session;
    private Configuration $jwtConfig;

    public function __construct(UserProviderInterface $userProvider, SessionInterface $session, string $jwtSecret)
    {
        $this->userProvider = $userProvider;
        $this->session = $session;


        $this->jwtConfig = Configuration::forSymmetricSigner(
            new Sha256(),
            InMemory::plainText($jwtSecret)
        );


    }

    public function supports(Request $request): ?bool
{
    // Do not activate JWT authentication for login route
    return $request->getPathInfo() !== '/' && $this->session->has('jwt');
}


    public function authenticate(Request $request): SelfValidatingPassport
    {
        $jwt = $this->session->get('jwt');
        error_log("[Auth] JWT from session: " . $jwt);

        if (!$jwt) {
            error_log("[Auth] No JWT found in session.");
            throw new AuthenticationException("Missing JWT");
        }

        try {
            $token = $this->jwtConfig->parser()->parse($jwt);
            error_log("[Auth] Token parsed successfully");

            if (!$token instanceof Plain) {
                error_log("[Auth] Token is not instance of Plain");
                throw new AuthenticationException('Unexpected token type');
            }

            $constraints = [
                new \Lcobucci\JWT\Validation\Constraint\SignedWith(
                    $this->jwtConfig->signer(),
                    $this->jwtConfig->verificationKey()
                ),
                new \Lcobucci\JWT\Validation\Constraint\ValidAt(
                    new \Lcobucci\Clock\SystemClock(new \DateTimeZone('UTC'))
                ),
            ];

            $isValid = $this->jwtConfig->validator()->validate($token, ...$constraints);
            error_log("[Auth] Token validation result: " . ($isValid ? "valid" : "invalid"));

            if (!$isValid) {
                throw new AuthenticationException('JWT is invalid or expired.');
            }

            $username = $token->claims()->get('sub');
            $role = null;
            if ($token->claims()->has('roles')) {
                $claim = $token->claims()->get('roles');
                if (is_array($claim) && !empty($claim)) {
                    // Take the highest role (ADMIN > USER)
                    $role = in_array('ROLE_ADMIN', $claim) ? 'ADMIN' : 'USER';
                } elseif (is_string($claim)) {
                    $decoded = json_decode($claim, true);
                    if (is_array($decoded) && !empty($decoded)) {
                        $role = in_array('ROLE_ADMIN', $decoded) ? 'ADMIN' : 'USER';
                    }
                }
            }
            error_log("[Auth] Token role: " . ($role ?? 'USER'));

            return new SelfValidatingPassport(
                new UserBadge($username, function ($userIdentifier) use ($role) {
                    $user = $this->userProvider->loadUserByIdentifier($userIdentifier);
                    if ($role !== null) {
                        $user->setRole($role);
                    }
                    return $user;
                })
            );
            

        } catch (\Throwable $e) {
            error_log("[Auth] Exception: " . $e->getMessage());
            throw new AuthenticationException('JWT authentication failed: ' . $e->getMessage());
        }
    }

    public function onAuthenticationSuccess(Request $request, $token, string $firewallName): ?Response
    {
        return null;
    }

    public function onAuthenticationFailure(Request $request, AuthenticationException $exception): ?Response
    {
        throw $exception;
    }
}
