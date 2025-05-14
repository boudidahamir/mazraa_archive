package com.mazraa.archive.controller;

import com.mazraa.archive.dto.DocumentTypeCreateRequest;
import com.mazraa.archive.dto.DocumentTypeDTO;
import com.mazraa.archive.dto.DocumentTypeUpdateRequest;
import com.mazraa.archive.security.CustomUserDetails;
import com.mazraa.archive.service.DocumentTypeService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/document-types")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class DocumentTypeController {

    private final DocumentTypeService documentTypeService;

    @PostMapping
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<DocumentTypeDTO> createDocumentType(
            @Valid @RequestBody DocumentTypeCreateRequest request,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(documentTypeService.createDocumentType(request, userDetails.getId()));
    }

    @PutMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<DocumentTypeDTO> updateDocumentType(
            @PathVariable Long id,
            @Valid @RequestBody DocumentTypeUpdateRequest request,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(documentTypeService.updateDocumentType(id, request, userDetails.getId()));
    }

    @GetMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<DocumentTypeDTO> getDocumentType(@PathVariable Long id) {
        return ResponseEntity.ok(documentTypeService.getDocumentType(id));
    }

    @GetMapping("/code/{code}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<DocumentTypeDTO> getDocumentTypeByCode(@PathVariable String code) {
        return ResponseEntity.ok(documentTypeService.getDocumentTypeByCode(code));
    }

    @GetMapping("/search")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Page<DocumentTypeDTO>> searchDocumentTypes(
            @RequestParam String searchTerm,
            Pageable pageable) {
        return ResponseEntity.ok(documentTypeService.searchDocumentTypes(searchTerm, pageable));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Void> deleteDocumentType(@PathVariable Long id) {
        documentTypeService.deleteDocumentType(id);
        return ResponseEntity.ok().build();
    }
} 