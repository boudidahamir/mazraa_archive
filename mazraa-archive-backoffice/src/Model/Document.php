<?php

namespace App\Model;

use Symfony\Component\Validator\Constraints as Assert;

class Document
{
    private ?int $id = null;

    #[Assert\NotBlank]
    private ?string $title = null;

    #[Assert\NotBlank]
    private ?string $documentType = null;

    #[Assert\NotBlank]
    private ?string $status = 'ACTIVE';

    private ?string $barcode = null;

    private ?string $description = null;

    private ?string $storageLocation = null;

    private ?\DateTimeImmutable $createdAt = null;

    private ?\DateTimeImmutable $updatedAt = null;

    private ?\DateTimeImmutable $archivedAt = null;

    public static function fromApiResponse(array $data): self
    {
        $document = new self();
        $document->setId($data['id'] ?? null);
        $document->setTitle($data['title'] ?? '');
        $document->setDocumentType(isset($data['documentType']) && isset($data['documentType']['id']) 
            ? (string)$data['documentType']['id'] 
            : null);
        $document->setStatus($data['status'] ?? 'ACTIVE');
        $document->setBarcode($data['barcode'] ?? null);
        $document->setDescription($data['description'] ?? null);
        $document->setStorageLocation(isset($data['storageLocation']) && isset($data['storageLocation']['id']) 
            ? (string)$data['storageLocation']['id'] 
            : null);
    
        if (isset($data['createdAt'])) {
            $document->setCreatedAt(new \DateTimeImmutable($data['createdAt']));
        }
        if (isset($data['updatedAt'])) {
            $document->setUpdatedAt(new \DateTimeImmutable($data['updatedAt']));
        }
        if (isset($data['archivedAt'])) {
            $document->setArchivedAt(new \DateTimeImmutable($data['archivedAt']));
        }
    
        return $document;
    }
    

    public function toApiRequest(): array
    {
        return [
            'title' => $this->title,
            'documentTypeId' => $this->documentType ? (int)$this->documentType : null,
            'status' => $this->status,
            'description' => $this->description,
            'barcode' => $this->barcode,
            'storageLocationId' => $this->storageLocation ? (int)$this->storageLocation : null
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

    public function getTitle(): ?string
    {
        return $this->title;
    }

    public function setTitle(string $title): self
    {
        $this->title = $title;
        return $this;
    }

    public function getDocumentType(): ?string
    {
        return $this->documentType;
    }

    public function setDocumentType(?string $documentType): self
    {
        $this->documentType = $documentType;
        return $this;
    }

    public function getStatus(): ?string
    {
        return $this->status;
    }

    public function setStatus(string $status): self
    {
        $this->status = $status;
        return $this;
    }

    public function getBarcode(): ?string
    {
        return $this->barcode;
    }

    public function setBarcode(?string $barcode): self
    {
        $this->barcode = $barcode;
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

    public function getStorageLocation(): ?string
    {
        return $this->storageLocation;
    }

    public function setStorageLocation(?string $storageLocation): self
    {
        $this->storageLocation = $storageLocation;
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

    public function getArchivedAt(): ?\DateTimeImmutable
    {
        return $this->archivedAt;
    }

    public function setArchivedAt(?\DateTimeImmutable $archivedAt): self
    {
        $this->archivedAt = $archivedAt;
        return $this;
    }

    public function getStatusLabel(): string
    {
        return match ($this->status) {
            'ACTIVE' => 'Actif',
            'ARCHIVED' => 'Archivé',
            'RETRIEVED' => 'Retiré',
            'DESTROYED' => 'Détruit',
            default => 'Inconnu'
        };
    }

    public function getStatusColor(): string
    {
        return match ($this->status) {
            'ACTIVE' => 'success',
            'ARCHIVED' => 'warning',
            'RETRIEVED' => 'info',
            'DESTROYED' => 'danger',
            default => 'secondary'
        };
    }
}