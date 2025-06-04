package com.mazraa.archive.controller;

import com.mazraa.archive.dto.DocumentTypeCreateRequest;
import com.mazraa.archive.dto.DocumentTypeDTO;
import com.mazraa.archive.dto.DocumentTypeUpdateRequest;
import com.mazraa.archive.repository.DocumentTypeRepository;
import com.mazraa.archive.security.UserDetailsImpl;
import com.mazraa.archive.service.DocumentTypeService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
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

    @GetMapping("/search")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Page<DocumentTypeDTO>> searchDocumentTypes(
            @RequestParam(required = false) String searchTerm,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            Pageable pageable) {
        return ResponseEntity.ok(documentTypeService.searchDocumentTypes(searchTerm, startDate, endDate, pageable));
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<DocumentTypeDTO>> getAllDocumentTypes() {
        return ResponseEntity.ok(documentTypeService.getAllDocumentTypes());
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<DocumentTypeDTO> createDocumentType(
            @Valid @RequestBody DocumentTypeCreateRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
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

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> deleteDocumentType(@PathVariable Long id) {
        documentTypeService.deleteDocumentType(id);
        return ResponseEntity.ok().build();
    }
}