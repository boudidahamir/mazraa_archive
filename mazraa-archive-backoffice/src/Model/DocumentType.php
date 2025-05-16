<?php

namespace App\Model;

class DocumentType
{
    private ?int $id = null;
    private string $name;
    private string $description;
    private string $code;
    private ?string $createdAt = null;
    private ?string $updatedAt = null;
    private ?int $createdById = null;
    private ?int $updatedById = null;

    public function getId(): ?int
    {
        return $this->id;
    }

    public function setId(?int $id): void
    {
        $this->id = $id;
    }

    public function getName(): string
    {
        return $this->name;
    }

    public function setName(string $name): void
    {
        $this->name = $name;
    }

    public function getDescription(): string
    {
        return $this->description;
    }

    public function setDescription(string $description): void
    {
        $this->description = $description;
    }

    public function getCode(): string
    {
        return $this->code;
    }

    public function setCode(string $code): void
    {
        $this->code = $code;
    }

    public function getCreatedAt(): ?string
    {
        return $this->createdAt;
    }

    public function setCreatedAt(?string $createdAt): void
    {
        $this->createdAt = $createdAt;
    }

    public function getUpdatedAt(): ?string
    {
        return $this->updatedAt;
    }

    public function setUpdatedAt(?string $updatedAt): void
    {
        $this->updatedAt = $updatedAt;
    }

    public function getCreatedById(): ?int
    {
        return $this->createdById;
    }

    public function setCreatedById(?int $createdById): void
    {
        $this->createdById = $createdById;
    }

    public function getUpdatedById(): ?int
    {
        return $this->updatedById;
    }

    public function setUpdatedById(?int $updatedById): void
    {
        $this->updatedById = $updatedById;
    }

    // Converts PHP model to array for API request
    public function toApiRequest(): array
    {
        return [
            'name' => $this->name,
            'description' => $this->description,
            'code' => $this->code,
        ];
    }

    // Creates instance from API response
    public static function fromApiResponse(array $data): self
    {
        $type = new self();
        $type->setId($data['id'] ?? null);
        $type->setName($data['name'] ?? '');
        $type->setDescription($data['description'] ?? '');
        $type->setCode($data['code'] ?? '');
        $type->setCreatedAt($data['createdAt'] ?? null);
        $type->setUpdatedAt($data['updatedAt'] ?? null);
        $type->setCreatedById($data['createdBy']['id'] ?? null);
        $type->setUpdatedById($data['updatedBy']['id'] ?? null);

        return $type;
    }
}
