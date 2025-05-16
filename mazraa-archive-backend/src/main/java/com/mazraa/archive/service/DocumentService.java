package com.mazraa.archive.service;

import com.mazraa.archive.dto.DocumentCreateRequest;
import com.mazraa.archive.dto.DocumentDTO;
import com.mazraa.archive.dto.DocumentUpdateRequest;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.web.multipart.MultipartFile;

public interface DocumentService {
    DocumentDTO createDocument(DocumentCreateRequest request, MultipartFile file, Long userId);
    DocumentDTO updateDocument(Long id, DocumentUpdateRequest request, MultipartFile file, Long userId);
    DocumentDTO getDocument(Long id);
    DocumentDTO getDocumentByBarcode(String barcode);
    Page<DocumentDTO> searchDocuments(String searchTerm, Pageable pageable);
    Page<DocumentDTO> getDocumentsByType(Long documentTypeId, Pageable pageable);
    Page<DocumentDTO> getDocumentsByLocation(Long storageLocationId, Pageable pageable);
    Page<DocumentDTO> getDocumentsByUser(Long userId, Pageable pageable);
    Page<DocumentDTO> getArchivedDocuments(boolean archived, Pageable pageable);
    void archiveDocument(Long id, Long userId);
    void deleteDocument(Long id);
    byte[] downloadDocument(Long id);
    List<DocumentDTO> getAllDocuments();
} 