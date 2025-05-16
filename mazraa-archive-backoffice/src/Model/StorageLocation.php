<?php

namespace App\Model;

class StorageLocation
{
    private ?int $id = null;
    private ?string $name = null;
    private ?string $description = null;
    private ?string $path = null;
    private ?bool $isActive = true;
    private ?\DateTimeImmutable $createdAt = null;
    private ?\DateTimeImmutable $updatedAt = null;

    public static function fromApiResponse(array $data): self
    {
        $storageLocation = new self();
        $storageLocation->setId($data['id']);
        $storageLocation->setName($data['name']);
        $storageLocation->setDescription($data['description'] ?? null);
        $storageLocation->setPath($data['path']);
        $storageLocation->setIsActive($data['isActive']);
        
        if (isset($data['createdAt'])) {
            $storageLocation->setCreatedAt(new \DateTimeImmutable($data['createdAt']));
        }
        if (isset($data['updatedAt'])) {
            $storageLocation->setUpdatedAt(new \DateTimeImmutable($data['updatedAt']));
        }

        return $storageLocation;
    }

    public function toApiRequest(): array
    {
        return [
            'name' => $this->name,
            'description' => $this->description,
            'path' => $this->path,
            'isActive' => $this->isActive,
        ];
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

    public function getName(): ?string
    {
        return $this->name;
    }

    public function setName(string $name): self
    {
        $this->name = $name;
        return $this;
    }

    public function getDescription(): ?string
    {
        return $this->description;
    }

    public function setDescription(?string $description): self
    {
        $this->description = $description;
        return $this;
    }

    public function getPath(): ?string
    {
        return $this->path;
    }

    public function setPath(string $path): self
    {
        $this->path = $path;
        return $this;
    }

    public function isActive(): ?bool
    {
        return $this->isActive;
    }

    public function setIsActive(bool $isActive): self
    {
        $this->isActive = $isActive;
        return $this;
    }

    public function getCreatedAt(): ?\DateTimeImmutable
    {
        return $this->createdAt;
    }

    public function setCreatedAt(?\DateTimeImmutable $createdAt): self
    {
        $this->createdAt = $createdAt;
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
} 