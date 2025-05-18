<?php

namespace App\Model;

use Symfony\Component\Security\Core\User\PasswordAuthenticatedUserInterface;
use Symfony\Component\Security\Core\User\UserInterface;

class User implements UserInterface, PasswordAuthenticatedUserInterface
{
    private ?int $id = null;
    private ?string $username = null;
    private ?string $email = null;
    private ?string $password = null;
    private ?string $role = null;
    private ?array $roles = [];
    private ?string $fullName = null;
    private ?bool $enabled = true;
    private ?\DateTimeImmutable $createdAt = null;
    private ?\DateTimeImmutable $lastLoginAt = null;

    public function __construct()
    {
        $this->createdAt = new \DateTimeImmutable();
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

    public function setRole(string $role): self
    {
        $this->role = $role;
        return $this;
    }

    public function getRoles(): array
{
    return $this->roles ?? ['ROLE_USER'];
}



    public function setRoles(array $roles): self
    {
        $this->roles = $roles;
        return $this;
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

    public function toArray(string $plainPassword = null): array
    {
        return [
            'username' => $this->getUsername(),
            'email' => $this->getEmail(),
            'fullName' => $this->getFullName(),
            'password' => $plainPassword, // récupéré depuis le formulaire
            'role' => $this->getRole(), // supposons un seul rôle
            'roles' => $this->getRoles(),
            'enabled' => $this->enabled(),
        ];
    }

    public static function fromArray(array $data): self
    {
        $user = new self();

        $user->setId($data['id'] ?? null);
        $user->setUsername($data['username'] ?? '');
        $user->setEmail($data['email'] ?? '');
        $user->setFullName($data['fullName'] ?? '');
        $user->setRole($data['role'] ?? '');
        $user->setRoles([$data['role'] ?? '']); // pour hydrater le champ Symfony (ChoiceType multiple)
        $user->setenabled($data['enabled'] ?? false);

        return $user;
    }

}