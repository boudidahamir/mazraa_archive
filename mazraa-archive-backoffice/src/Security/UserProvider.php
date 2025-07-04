<?php

namespace App\Security;

use App\Model\User;
use App\Service\ApiService;
use Symfony\Component\Security\Core\Exception\UserNotFoundException;
use Symfony\Component\Security\Core\Exception\UnsupportedUserException;
use Symfony\Component\Security\Core\User\UserInterface;
use Symfony\Component\Security\Core\User\UserProviderInterface;

class UserProvider implements UserProviderInterface
{
    private $apiService;

    public function __construct(ApiService $apiService)
    {
        $this->apiService = $apiService;
    }

    public function loadUserByIdentifier(string $identifier): UserInterface
    {
        error_log("[UserProvider] Looking up user: " . $identifier);

        try {
            $userData = $this->apiService->getUserByUsername($identifier);
            $user = new User();
            $user->setId($userData['id']);
            $user->setUsername($userData['username']);
            $user->setEmail($userData['email']);
            $user->setPassword($userData['password']);
            
            // Handle role
            if (isset($userData['role'])) {
                $user->setRole($userData['role']);
            }
            
            $user->setFullName($userData['fullname'] ?? ''); // fallback
            $user->setenabled($userData['enabled'] ?? true); // use "enabled" instead of "isActive"

            if (isset($userData['createdAt'])) {
                $user->setCreatedAt(new \DateTimeImmutable($userData['createdAt']));
            }
            if (isset($userData['lastLoginAt'])) {
                $user->setLastLoginAt(new \DateTimeImmutable($userData['lastLoginAt']));
            }

            if (!$user->enabled()) {
                throw new UserNotFoundException('User account is disabled.');
            }

            return $user;
        } catch (\Exception $e) {
            throw new UserNotFoundException(sprintf('User with username "%s" not found.', $identifier));
        }
    }

    public function refreshUser(UserInterface $user): UserInterface
    {
        if (!$user instanceof User) {
            throw new UnsupportedUserException(sprintf('Instances of "%s" are not supported.', \get_class($user)));
        }

        return $this->loadUserByIdentifier($user->getUserIdentifier());
    }

    public function supportsClass(string $class): bool
    {
        return User::class === $class || is_subclass_of($class, User::class);
    }

    public function loadUserByUsername(string $username)
    {
        return $this->loadUserByIdentifier($username);
    }
}