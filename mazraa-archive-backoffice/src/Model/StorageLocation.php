<?php

namespace App\Model;

class StorageLocation
{
    private ?int $id = null;
    private ?string $code = null;
    private ?string $name = null;
    private ?string $description = null;
    private ?string $shelf = null;
    private ?string $row = null;
    private ?string $box = null;
    private ?int $capacity = null;
    private ?bool $isActive = true;
    private ?\DateTimeImmutable $createdAt = null;
    private ?\DateTimeImmutable $updatedAt = null;
    private ?int $usedSpace = 0;

    public static function fromApiResponse(array $data): self
    {
        $storageLocation = new self();
        $storageLocation->setId($data['id'] ?? null);
        $storageLocation->setCode($data['code'] ?? null);
        $storageLocation->setName($data['name']);
        $storageLocation->setDescription($data['description'] ?? null);
        $storageLocation->setShelf($data['shelf'] ?? null);
        $storageLocation->setRow($data['row'] ?? null);
        $storageLocation->setBox($data['box'] ?? null);
        $storageLocation->setCapacity($data['capacity'] ?? null);
        $storageLocation->setIsActive($data['active'] ?? true);
        $storageLocation->setUsedSpace($data['usedSpace'] ?? 0);

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
            'code' => $this->code,
            'name' => $this->name,
            'description' => $this->description,
            'shelf' => $this->shelf,
            'row' => $this->row,
            'box' => $this->box,
            'capacity' => $this->capacity,
            'active' => $this->isActive,
        ];
    }

    // Add all necessary getters and setters...

    public function getCode(): ?string
    {
        return $this->code;
    }
    public function setCode(string $code): self
    {
        $this->code = $code;
        return $this;
    }

    public function getShelf(): ?string
    {
        return $this->shelf;
    }
    public function setShelf(string $shelf): self
    {
        $this->shelf = $shelf;
        return $this;
    }

    public function getRow(): ?string
    {
        return $this->row;
    }
    public function setRow(string $row): self
    {
        $this->row = $row;
        return $this;
    }

    public function getBox(): ?string
    {
        return $this->box;
    }
    public function setBox(string $box): self
    {
        $this->box = $box;
        return $this;
    }

    public function getCapacity(): ?int
    {
        return $this->capacity;
    }
    public function setCapacity(int $capacity): self
    {
        $this->capacity = $capacity;
        return $this;
    }

    // Ajoute ceci dans App\Model\StorageLocation

    public function getId(): ?int
    {
        return $this->id;
    }

    public function getName(): ?string
    {
        return $this->name;
    }

    public function setName(?string $name): self
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

    public function setId(?int $id): self
    {
        $this->id = $id;
        return $this;
    }
    public function getIsActive(): ?bool
    {
        return $this->isActive;
    }

    public function setIsActive(?bool $isActive): self
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

    public function getUsedSpace(): ?int
    {
        return $this->usedSpace;
    }

    public function setUsedSpace(?int $usedSpace): self
    {
        $this->usedSpace = $usedSpace;
        return $this;
    }
}
