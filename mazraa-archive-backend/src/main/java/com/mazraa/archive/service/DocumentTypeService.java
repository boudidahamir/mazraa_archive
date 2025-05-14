package com.mazraa.archive.service;

import com.mazraa.archive.dto.DocumentTypeCreateRequest;
import com.mazraa.archive.dto.DocumentTypeDTO;
import com.mazraa.archive.dto.DocumentTypeUpdateRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface DocumentTypeService {
    DocumentTypeDTO createDocumentType(DocumentTypeCreateRequest request, Long userId);
    DocumentTypeDTO updateDocumentType(Long id, DocumentTypeUpdateRequest request, Long userId);
    DocumentTypeDTO getDocumentType(Long id);
    DocumentTypeDTO getDocumentTypeByCode(String code);
    Page<DocumentTypeDTO> searchDocumentTypes(String searchTerm, Pageable pageable);
    void deleteDocumentType(Long id);
} 