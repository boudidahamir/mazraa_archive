<?php

namespace App\Model;

use Symfony\Component\Security\Core\User\PasswordAuthenticatedUserInterface;
use Symfony\Component\Security\Core\User\UserInterface;

class User implements UserInterface, PasswordAuthenticatedUserInterface
{
    public const ROLE_USER = 'USER';
    public const ROLE_ADMIN = 'ADMIN';

    private ?int $id = null;
    private ?string $username = null;
    private ?string $email = null;
    private ?string $password = null;
    private ?string $role = self::ROLE_USER;
    private ?string $fullName = null;
    private ?bool $enabled = true;
    private ?\DateTimeImmutable $createdAt = null;
    private ?\DateTimeImmutable $lastLoginAt = null;
    private ?\DateTimeImmutable $updatedAt = null;
    private ?int $createdById = null;
    private ?string $createdByName = null;
    private ?int $updatedById = null;
    private ?string $updatedByName = null;

    public function __construct()
    {
        $this->createdAt = new \DateTimeImmutable();
        $this->updatedAt = new \DateTimeImmutable();
    }

    public function getId(): ?int
    {
        return $this->id;
    }

    public function setId(?int $id): self
    {
        $this->id = $id;
        return $this;
    }

    public function getUsername(): ?string
    {
        return $this->username;
    }

    public function setUsername(string $username): self
    {
        $this->username = $username;
        return $this;
    }

    public function getUserIdentifier(): string
    {
        return (string) $this->username;
    }

    public function getRole(): ?string
    {
        return $this->role;
    }

    public function setRole(?string $role): self
    {
        // Don't modify the role case, use it as is
        $this->role = $role ?? self::ROLE_USER;
        return $this;
    }

    /**
     * Returns the roles granted to the user.
     * This method is required by the Symfony Security system.
     */
    public function getRoles(): array
    {
        // Convert role to Symfony format (e.g., 'ADMIN' -> 'ROLE_ADMIN')
        $roles = ['ROLE_' . $this->role];
        
        // Always include ROLE_USER as per Symfony best practices
        if (!in_array('ROLE_USER', $roles)) {
            $roles[] = 'ROLE_USER';
        }
        
        error_log("[User] Getting roles for user {$this->username}: " . json_encode($roles));
        return array_unique($roles);
    }

    public function getPassword(): string
    {
        return $this->password ?? '';
    }

    public function setPassword(string $password): self
    {
        $this->password = $password;
        return $this;
    }

    public function getSalt(): ?string
    {
        // Not needed when using the "auto" algorithm in security.yaml
        return null;
    }

    public function getEmail(): ?string
    {
        return $this->email;
    }

    public function setEmail(string $email): self
    {
        $this->email = $email;
        return $this;
    }

    public function enabled(): ?bool
    {
        return $this->enabled;
    }

    public function setenabled(bool $enabled): self
    {
        $this->enabled = $enabled;
        return $this;
    }

    public function getCreatedAt(): ?\DateTimeImmutable
    {
        return $this->createdAt;
    }

    public function getLastLoginAt(): ?\DateTimeImmutable
    {
        return $this->lastLoginAt;
    }

    public function setLastLoginAt(?\DateTimeImmutable $lastLoginAt): self
    {
        $this->lastLoginAt = $lastLoginAt;
        return $this;
    }

    public function eraseCredentials(): void
    {
        // If you store any temporary, sensitive data on the user, clear it here
    }

    public function setCreatedAt(\DateTimeImmutable $createdAt): self
    {
        $this->createdAt = $createdAt;
        return $this;
    }

    public function getFullName(): ?string
    {
        return $this->fullName;
    }

    public function setFullName(string $fullName): self
    {
        $this->fullName = $fullName;
        return $this;
    }

    public function getUpdatedAt(): ?\DateTimeImmutable
    {
        return $this->updatedAt;
    }

    public function setUpdatedAt(?\DateTimeImmutable $updatedAt): self
    {
        $this->updatedAt = $updatedAt;
        return $this;
    }

    public function getCreatedById(): ?int
    {
        return $this->createdById;
    }

    public function setCreatedById(?int $createdById): self
    {
        $this->createdById = $createdById;
        return $this;
    }

    public function getCreatedByName(): ?string
    {
        return $this->createdByName;
    }

    public function setCreatedByName(?string $createdByName): self
    {
        $this->createdByName = $createdByName;
        return $this;
    }

    public function getUpdatedById(): ?int
    {
        return $this->updatedById;
    }

    public function setUpdatedById(?int $updatedById): self
    {
        $this->updatedById = $updatedById;
        return $this;
    }

    public function getUpdatedByName(): ?string
    {
        return $this->updatedByName;
    }

    public function setUpdatedByName(?string $updatedByName): self
    {
        $this->updatedByName = $updatedByName;
        return $this;
    }

    public function toArray(string $plainPassword = null): array
    {
        return [
            'username' => $this->getUsername(),
            'email' => $this->getEmail(),
            'fullName' => $this->getFullName(),
            'password' => $plainPassword,
            'role' => $this->getRole(),
            'enabled' => $this->enabled(),
            'roles' => 'ROLE_' . $this->getRole(),
            'isActive' => true,
            'updatedAt' => $this->getUpdatedAt()?->format('Y-m-d\TH:i:s'),
            'createdAt' => $this->getCreatedAt()?->format('Y-m-d\TH:i:s'),
            'createdById' => $this->getCreatedById(),
            'createdByName' => $this->getCreatedByName(),
            'updatedById' => $this->getUpdatedById(),
            'updatedByName' => $this->getUpdatedByName(),
        ];
    }

    public static function fromArray(array $data): self
    {
        $user = new self();

        $user->setId($data['id'] ?? null);
        $user->setUsername($data['username'] ?? '');
        $user->setEmail($data['email'] ?? '');
        $user->setFullName($data['fullName'] ?? '');
        $user->setRole($data['role'] ?? self::ROLE_USER);
        $user->setenabled($data['enabled'] ?? false);
        
        if (isset($data['updatedAt'])) {
            $user->setUpdatedAt(new \DateTimeImmutable($data['updatedAt']));
        }
        if (isset($data['createdAt'])) {
            $user->setCreatedAt(new \DateTimeImmutable($data['createdAt']));
        }
        
        $user->setCreatedById($data['createdById'] ?? null);
        $user->setCreatedByName($data['createdByName'] ?? null);
        $user->setUpdatedById($data['updatedById'] ?? null);
        $user->setUpdatedByName($data['updatedByName'] ?? null);

        return $user;
    }
}