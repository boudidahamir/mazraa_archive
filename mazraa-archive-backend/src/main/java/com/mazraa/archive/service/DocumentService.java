package com.mazraa.archive.service;

import com.mazraa.archive.dto.DocumentCreateRequest;
import com.mazraa.archive.dto.DocumentDTO;
import com.mazraa.archive.dto.DocumentUpdateRequest;

import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface DocumentService {
    DocumentDTO createDocument(DocumentCreateRequest request, Long userId);
    DocumentDTO updateDocument(Long id, DocumentUpdateRequest request, Long userId);
    DocumentDTO getDocument(Long id);
    DocumentDTO getDocumentByBarcode(String barcode);
    Page<DocumentDTO> searchDocuments(String searchTerm, Pageable pageable);
    Page<DocumentDTO> getDocumentsByType(Long documentTypeId, Pageable pageable);
    Page<DocumentDTO> getDocumentsByLocation(Long storageLocationId, Pageable pageable);
    Page<DocumentDTO> getDocumentsByUser(Long userId, Pageable pageable);
    Page<DocumentDTO> getArchivedDocuments(boolean archived, Pageable pageable);
    void archiveDocument(Long id, Long userId);
    void deleteDocument(Long id);
    List<DocumentDTO> getAllDocuments();
    List<DocumentDTO> getDocumentsByTypeCode(String code);
    
}
