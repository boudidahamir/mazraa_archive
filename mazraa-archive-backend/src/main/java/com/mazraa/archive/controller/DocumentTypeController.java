package com.mazraa.archive.controller;

import com.mazraa.archive.dto.DocumentTypeCreateRequest;
import com.mazraa.archive.dto.DocumentTypeDTO;
import com.mazraa.archive.dto.DocumentTypeUpdateRequest;
import com.mazraa.archive.repository.DocumentTypeRepository;
import com.mazraa.archive.security.UserDetailsImpl;
import com.mazraa.archive.service.DocumentTypeService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/document-types")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class DocumentTypeController {

    private final DocumentTypeService documentTypeService;
    private final DocumentTypeRepository documentTypeRepository;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<DocumentTypeDTO>> getAllDocumentTypes() {
        List<DocumentTypeDTO> result = documentTypeRepository.findAll().stream()
                .map(dt -> {
                    DocumentTypeDTO dto = new DocumentTypeDTO();
                    dto.setId(dt.getId());
                    dto.setName(dt.getName());
                    dto.setCode(dt.getCode());
                    dto.setDescription(dt.getDescription());
                    dto.setCreatedAt(dt.getCreatedAt());
                    dto.setUpdatedAt(dt.getUpdatedAt());

                    if (dt.getCreatedBy() != null) {
                        dto.setCreatedById(dt.getCreatedBy().getId());
                        dto.setCreatedByName(dt.getCreatedBy().getFullName());
                    }

                    if (dt.getUpdatedBy() != null) {
                        dto.setUpdatedById(dt.getUpdatedBy().getId());
                        dto.setUpdatedByName(dt.getUpdatedBy().getFullName());
                    }

                    return dto;
                })
                .toList();

        return ResponseEntity.ok(result);
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<DocumentTypeDTO> createDocumentType(
            @Valid @RequestBody DocumentTypeCreateRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        System.err.println(">>> Controller: userDetails ID = " + userDetails.getId());
        System.err.println(">>> userDetails ID: " + userDetails.getId());
        return ResponseEntity.ok(documentTypeService.createDocumentType(request, userDetails.getId()));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<DocumentTypeDTO> updateDocumentType(
            @PathVariable Long id,
            @Valid @RequestBody DocumentTypeUpdateRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        return ResponseEntity.ok(documentTypeService.updateDocumentType(id, request, userDetails.getId()));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<DocumentTypeDTO> getDocumentType(@PathVariable Long id) {
        return ResponseEntity.ok(documentTypeService.getDocumentType(id));
    }

    @GetMapping("/code/{code}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<DocumentTypeDTO> getDocumentTypeByCode(@PathVariable String code) {
        return ResponseEntity.ok(documentTypeService.getDocumentTypeByCode(code));
    }

    @GetMapping("/search")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Page<DocumentTypeDTO>> searchDocumentTypes(
            @RequestParam String searchTerm,
            Pageable pageable) {
        return ResponseEntity.ok(documentTypeService.searchDocumentTypes(searchTerm, pageable));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteDocumentType(@PathVariable Long id) {
        documentTypeService.deleteDocumentType(id);
        return ResponseEntity.ok().build();
    }
}