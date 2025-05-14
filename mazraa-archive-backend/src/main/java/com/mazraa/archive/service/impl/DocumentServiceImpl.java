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
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class DocumentServiceImpl implements DocumentService {

    private final DocumentRepository documentRepository;
    private final DocumentTypeRepository documentTypeRepository;
    private final StorageLocationRepository storageLocationRepository;
    private final UserRepository userRepository;
    private final String UPLOAD_DIR = "uploads/documents";

    @Override
    @Transactional
    public DocumentDTO createDocument(DocumentCreateRequest request, MultipartFile file, Long userId) {
        if (documentRepository.existsByBarcode(request.getBarcode())) {
            throw new ResourceAlreadyExistsException("Document with barcode " + request.getBarcode() + " already exists");
        }

        DocumentType documentType = documentTypeRepository.findById(request.getDocumentTypeId())
                .orElseThrow(() -> new ResourceNotFoundException("Document type not found"));

        StorageLocation storageLocation = storageLocationRepository.findById(request.getStorageLocationId())
                .orElseThrow(() -> new ResourceNotFoundException("Storage location not found"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        String filePath = saveFile(file);

        Document document = new Document();
        document.setDocumentType(documentType);
        document.setBarcode(request.getBarcode());
        document.setTitle(request.getTitle());
        document.setDescription(request.getDescription());
        document.setStorageLocation(storageLocation);
        document.setFilePath(filePath);
        document.setFileType(file.getContentType());
        document.setFileSize(file.getSize());
        document.setArchived(false);
        document.setCreatedBy(user);

        return convertToDTO(documentRepository.save(document));
    }

    @Override
    @Transactional
    public DocumentDTO updateDocument(Long id, DocumentUpdateRequest request, MultipartFile file, Long userId) {
        Document document = documentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Document not found"));

        DocumentType documentType = documentTypeRepository.findById(request.getDocumentTypeId())
                .orElseThrow(() -> new ResourceNotFoundException("Document type not found"));

        StorageLocation storageLocation = storageLocationRepository.findById(request.getStorageLocationId())
                .orElseThrow(() -> new ResourceNotFoundException("Storage location not found"));

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        document.setDocumentType(documentType);
        document.setTitle(request.getTitle());
        document.setDescription(request.getDescription());
        document.setStorageLocation(storageLocation);
        document.setUpdatedBy(user);

        if (file != null && !file.isEmpty()) {
            deleteFile(document.getFilePath());
            String filePath = saveFile(file);
            document.setFilePath(filePath);
            document.setFileType(file.getContentType());
            document.setFileSize(file.getSize());
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

        deleteFile(document.getFilePath());
        documentRepository.delete(document);
    }

    @Override
    public byte[] downloadDocument(Long id) {
        Document document = documentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Document not found"));

        try {
            Path path = Paths.get(document.getFilePath());
            return Files.readAllBytes(path);
        } catch (IOException e) {
            throw new ResourceNotFoundException("File not found");
        }
    }

    private String saveFile(MultipartFile file) {
        try {
            Path uploadPath = Paths.get(UPLOAD_DIR);
            if (!Files.exists(uploadPath)) {
                Files.createDirectories(uploadPath);
            }

            String fileName = UUID.randomUUID().toString() + "_" + file.getOriginalFilename();
            Path filePath = uploadPath.resolve(fileName);
            Files.copy(file.getInputStream(), filePath);

            return filePath.toString();
        } catch (IOException e) {
            throw new RuntimeException("Failed to store file", e);
        }
    }

    private void deleteFile(String filePath) {
        try {
            Path path = Paths.get(filePath);
            Files.deleteIfExists(path);
        } catch (IOException e) {
            throw new RuntimeException("Failed to delete file", e);
        }
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
        dto.setFilePath(document.getFilePath());
        dto.setFileType(document.getFileType());
        dto.setFileSize(document.getFileSize());
        dto.setArchived(document.isArchived());
        dto.setArchivedAt(document.getArchivedAt());
        dto.setCreatedAt(document.getCreatedAt());
        dto.setUpdatedAt(document.getUpdatedAt());
        dto.setCreatedById(document.getCreatedBy().getId());
        dto.setCreatedByName(document.getCreatedBy().getFullName());
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
} 