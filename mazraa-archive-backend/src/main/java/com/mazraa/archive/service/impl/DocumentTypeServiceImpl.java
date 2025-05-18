package com.mazraa.archive.service.impl;

import com.mazraa.archive.dto.DocumentTypeCreateRequest;
import com.mazraa.archive.dto.DocumentTypeDTO;
import com.mazraa.archive.dto.DocumentTypeUpdateRequest;
import com.mazraa.archive.exception.ResourceAlreadyExistsException;
import com.mazraa.archive.exception.ResourceNotFoundException;
import com.mazraa.archive.model.DocumentType;
import com.mazraa.archive.model.User;
import com.mazraa.archive.repository.DocumentTypeRepository;
import com.mazraa.archive.repository.UserRepository;
import com.mazraa.archive.service.DocumentTypeService;
import lombok.RequiredArgsConstructor;

import java.time.LocalDateTime;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class DocumentTypeServiceImpl implements DocumentTypeService {

    private final DocumentTypeRepository documentTypeRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public DocumentTypeDTO createDocumentType(DocumentTypeCreateRequest request, Long userId) {
        try {
            if (documentTypeRepository.existsByCode(request.getCode())) {
                throw new ResourceAlreadyExistsException(
                        "Document type with code " + request.getCode() + " already exists");
            }

            if (documentTypeRepository.existsByName(request.getName())) {
                throw new ResourceAlreadyExistsException(
                        "Document type with name " + request.getName() + " already exists");
            }
            System.err.println(">>> DEBUG: Creating new DocumentType...");
            System.err.println(">>> Name: " + request.getName());
            System.err.println(">>> Code: " + request.getCode());
            
            User user = userRepository.findById(userId)
                    .orElseThrow(() -> new ResourceNotFoundException("User not found"));


                    
            System.err.println(">>> User ID: " + user.getId());
            System.err.println(">>> FullName: " + user.getFullName());        
            System.out.println("Saving entity...");    
                        
            DocumentType documentType = new DocumentType();
            documentType.setName(request.getName());
            documentType.setDescription(request.getDescription());
            documentType.setCode(request.getCode());
            documentType.setCreatedBy(user);
            documentType.setUpdatedBy(user);
            documentType.setCreatedAt(LocalDateTime.now());
            documentType.setUpdatedAt(LocalDateTime.now());

            return convertToDTO(documentTypeRepository.save(documentType));
        } catch (Exception e) {
            e.printStackTrace();
            throw e;
        }
    }

    @Override
    @Transactional
    public DocumentTypeDTO updateDocumentType(Long id, DocumentTypeUpdateRequest request, Long userId) {
        DocumentType documentType = documentTypeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Document type not found"));

        if (!documentType.getName().equals(request.getName()) &&
                documentTypeRepository.existsByName(request.getName())) {
            throw new ResourceAlreadyExistsException(
                    "Document type with name " + request.getName() + " already exists");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        documentType.setName(request.getName());
        documentType.setDescription(request.getDescription());
        documentType.setCode(request.getCode());
        documentType.setUpdatedBy(user);
        documentType.setUpdatedAt(LocalDateTime.now());
        return convertToDTO(documentTypeRepository.save(documentType));
    }

    @Override
    public DocumentTypeDTO getDocumentType(Long id) {
        return convertToDTO(documentTypeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Document type not found")));
    }

    @Override
    public DocumentTypeDTO getDocumentTypeByCode(String code) {
        return convertToDTO(documentTypeRepository.findByCode(code)
                .orElseThrow(() -> new ResourceNotFoundException("Document type not found")));
    }

    @Override
    public Page<DocumentTypeDTO> searchDocumentTypes(String searchTerm, Pageable pageable) {
        return documentTypeRepository.findAll(pageable)
                .map(this::convertToDTO);
    }

    @Override
    @Transactional
    public void deleteDocumentType(Long id) {
        DocumentType documentType = documentTypeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Document type not found"));
        documentTypeRepository.delete(documentType);
    }

    private DocumentTypeDTO convertToDTO(DocumentType documentType) {
        DocumentTypeDTO dto = new DocumentTypeDTO();
        dto.setId(documentType.getId());
        dto.setName(documentType.getName());
        dto.setDescription(documentType.getDescription());
        dto.setCode(documentType.getCode());
        dto.setCreatedAt(documentType.getCreatedAt());
        dto.setUpdatedAt(documentType.getUpdatedAt());
    
        if (documentType.getCreatedBy() != null) {
            dto.setCreatedById(documentType.getCreatedBy().getId());
            dto.setCreatedByName(documentType.getCreatedBy().getFullName());
        }
    
        if (documentType.getUpdatedBy() != null) {
            dto.setUpdatedById(documentType.getUpdatedBy().getId());
            dto.setUpdatedByName(documentType.getUpdatedBy().getFullName());
        }
    
        return dto;
    }
    
    
}