package com.mazraa.archive.service.impl;

import com.mazraa.archive.dto.DocumentCreateRequest;
import com.mazraa.archive.dto.DocumentDTO;
import com.mazraa.archive.dto.DocumentUpdateRequest;
import com.mazraa.archive.exception.ResourceAlreadyExistsException;
import com.mazraa.archive.exception.ResourceNotFoundException;
import com.mazraa.archive.model.Document;
import com.mazraa.archive.model.DocumentType;
import com.mazraa.archive.model.StorageLocation;
import com.mazraa.archive.model.User;
import com.mazraa.archive.repository.DocumentRepository;
import com.mazraa.archive.repository.DocumentTypeRepository;
import com.mazraa.archive.repository.StorageLocationRepository;
import com.mazraa.archive.repository.UserRepository;
import com.mazraa.archive.service.DocumentService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class DocumentServiceImpl implements DocumentService {

    private final DocumentRepository documentRepository;
    private final DocumentTypeRepository documentTypeRepository;
    private final StorageLocationRepository storageLocationRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public DocumentDTO createDocument(DocumentCreateRequest request, Long userId) {
        if (documentRepository.existsByBarcode(request.getBarcode())) {
            throw new ResourceAlreadyExistsException("Document with barcode " + request.getBarcode() + " already exists");
        }

        DocumentType documentType = documentTypeRepository.findById(request.getDocumentTypeId())
                .orElseThrow(() -> new ResourceNotFoundException("Document type not found"));

        StorageLocation storageLocation = storageLocationRepository.findById(request.getStorageLocationId())
                .orElseThrow(() -> new ResourceNotFoundException("Storage location not found"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        Document document = new Document();
        document.setDocumentType(documentType);
        document.setBarcode(request.getBarcode());
        document.setTitle(request.getTitle());
        document.setDescription(request.getDescription());
        document.setStorageLocation(storageLocation);
        document.setStatus(request.getStatus());
        document.setArchived(false);
        document.setCreatedBy(user);

        return convertToDTO(documentRepository.save(document));
    }

    @Override
    @Transactional
    public DocumentDTO updateDocument(Long id, DocumentUpdateRequest request, Long userId) {
        Document document = documentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Document not found"));

        DocumentType documentType = documentTypeRepository.findById(request.getDocumentTypeId())
                .orElseThrow(() -> new ResourceNotFoundException("Document type not found"));

        StorageLocation storageLocation = storageLocationRepository.findById(request.getStorageLocationId())
                .orElseThrow(() -> new ResourceNotFoundException("Storage location not found"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        document.setDocumentType(documentType);
        document.setBarcode(request.getBarcode());
        document.setTitle(request.getTitle());
        document.setDescription(request.getDescription());
        document.setStorageLocation(storageLocation);
        document.setStatus(request.getStatus());
        document.setUpdatedBy(user);

        if(request.getStatus() == "ARCHIVED"){
            System.out.println("Document is archived");
            document.setArchived(true);
            document.setArchivedAt(LocalDateTime.now());
            document.setArchivedBy(user);
        }
        else{
            document.setArchived(false);
            document.setArchivedAt(null);
            document.setArchivedBy(user);
        }
        return convertToDTO(documentRepository.save(document));
    }

    @Override
    public DocumentDTO getDocument(Long id) {
        return convertToDTO(documentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Document not found")));
    }

    

    @Override
    public DocumentDTO getDocumentByBarcode(String barcode) {
        return convertToDTO(documentRepository.findByBarcode(barcode)
                .orElseThrow(() -> new ResourceNotFoundException("Document not found")));
    }

    @Override
    public Page<DocumentDTO> searchDocuments(String searchTerm, Pageable pageable) {
        return documentRepository.searchDocuments(searchTerm, pageable)
                .map(this::convertToDTO);
    }

    @Override
    public Page<DocumentDTO> getDocumentsByType(Long documentTypeId, Pageable pageable) {
        return documentRepository.findByDocumentTypeId(documentTypeId, pageable)
                .map(this::convertToDTO);
    }

    @Override
    public Page<DocumentDTO> getDocumentsByLocation(Long storageLocationId, Pageable pageable) {
        return documentRepository.findByStorageLocationId(storageLocationId, pageable)
                .map(this::convertToDTO);
    }

    @Override
    public Page<DocumentDTO> getDocumentsByUser(Long userId, Pageable pageable) {
        return documentRepository.findByCreatedById(userId, pageable)
                .map(this::convertToDTO);
    }

    @Override
    public Page<DocumentDTO> getArchivedDocuments(boolean archived, Pageable pageable) {
        return documentRepository.findByArchived(archived, pageable)
                .map(this::convertToDTO);
    }

    @Override
    @Transactional
    public void archiveDocument(Long id, Long userId) {
        Document document = documentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Document not found"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        document.setArchived(true);
        document.setArchivedAt(LocalDateTime.now());
        document.setArchivedBy(user);

        documentRepository.save(document);
    }

    @Override
    @Transactional
    public void deleteDocument(Long id) {
        Document document = documentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Document not found"));

        documentRepository.delete(document);
    }


    @Override
    public List<DocumentDTO> getAllDocuments() {
        return documentRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    private DocumentDTO convertToDTO(Document document) {
        DocumentDTO dto = new DocumentDTO();
        dto.setId(document.getId());
        dto.setDocumentTypeId(document.getDocumentType().getId());
        dto.setDocumentTypeName(document.getDocumentType().getName());
        dto.setBarcode(document.getBarcode());
        dto.setTitle(document.getTitle());
        dto.setDescription(document.getDescription());
        dto.setStorageLocationId(document.getStorageLocation().getId());
        dto.setStorageLocationCode(document.getStorageLocation().getCode());
        dto.setArchived(document.isArchived());
        dto.setArchivedAt(document.getArchivedAt());
        dto.setCreatedAt(document.getCreatedAt());
        dto.setUpdatedAt(document.getUpdatedAt());
        dto.setCreatedById(document.getCreatedBy().getId());
        dto.setCreatedByName(document.getCreatedBy().getFullName());
        dto.setStatus(document.getStatus());
        if (document.getUpdatedBy() != null) {
            dto.setUpdatedById(document.getUpdatedBy().getId());
            dto.setUpdatedByName(document.getUpdatedBy().getFullName());
        }
        if (document.getArchivedBy() != null) {
            dto.setArchivedById(document.getArchivedBy().getId());
            dto.setArchivedByName(document.getArchivedBy().getFullName());
        }

        return dto;
    }

    @Override
    public List<DocumentDTO> getDocumentsByTypeCode(String code) {
        DocumentType type = documentTypeRepository.findByCode(code)
            .orElseThrow(() -> new IllegalArgumentException("Invalid document type code: " + code));
    
        List<Document> documents = documentRepository.findByDocumentType(type);
        return documents.stream().map(this::convertToDTO).collect(Collectors.toList());
    }
    
}
