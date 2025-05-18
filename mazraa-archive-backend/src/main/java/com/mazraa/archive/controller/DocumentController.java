package com.mazraa.archive.controller;

import com.mazraa.archive.annotation.AuditLog;
import com.mazraa.archive.dto.DocumentCreateRequest;
import com.mazraa.archive.dto.DocumentDTO;
import com.mazraa.archive.dto.DocumentUpdateRequest;
import com.mazraa.archive.security.UserDetailsImpl;
import com.mazraa.archive.service.DocumentService;
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
@RequestMapping("/documents")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class DocumentController {

    private final DocumentService documentService;

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<DocumentDTO>> getAllDocuments() {
        return ResponseEntity.ok(documentService.getAllDocuments());
    }

    
    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @AuditLog(action = "CREATE_DOCUMENT", entityType = "DOCUMENT", details = "Created new document")
    public ResponseEntity<DocumentDTO> createDocument(
            @Valid @RequestBody DocumentCreateRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        return ResponseEntity.ok(documentService.createDocument(request, userDetails.getId()));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @AuditLog(action = "UPDATE_DOCUMENT", entityType = "DOCUMENT", details = "Updated document information")
    public ResponseEntity<DocumentDTO> updateDocument(
            @PathVariable Long id,
            @Valid @RequestBody DocumentUpdateRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        return ResponseEntity.ok(documentService.updateDocument(id, request, userDetails.getId()));
    }

    @GetMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<DocumentDTO> getDocument(@PathVariable Long id) {
        return ResponseEntity.ok(documentService.getDocument(id));
    }

    @GetMapping("/barcode/{barcode}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<DocumentDTO> getDocumentByBarcode(@PathVariable String barcode) {
        return ResponseEntity.ok(documentService.getDocumentByBarcode(barcode));
    }

    @GetMapping("/search")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Page<DocumentDTO>> searchDocuments(
            @RequestParam String searchTerm,
            Pageable pageable) {
        return ResponseEntity.ok(documentService.searchDocuments(searchTerm, pageable));
    }
    

    @GetMapping("/type/{documentTypeId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Page<DocumentDTO>> getDocumentsByType(
            @PathVariable Long documentTypeId,
            Pageable pageable) {
        return ResponseEntity.ok(documentService.getDocumentsByType(documentTypeId, pageable));
    }

    @GetMapping("/location/{storageLocationId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Page<DocumentDTO>> getDocumentsByLocation(
            @PathVariable Long storageLocationId,
            Pageable pageable) {
        return ResponseEntity.ok(documentService.getDocumentsByLocation(storageLocationId, pageable));
    }

    @GetMapping("/user/{userId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Page<DocumentDTO>> getDocumentsByUser(
            @PathVariable Long userId,
            Pageable pageable) {
        return ResponseEntity.ok(documentService.getDocumentsByUser(userId, pageable));
    }

    @GetMapping("/archived")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Page<DocumentDTO>> getArchivedDocuments(
            @RequestParam boolean archived,
            Pageable pageable) {
        return ResponseEntity.ok(documentService.getArchivedDocuments(archived, pageable));
    }

    @PostMapping("/{id}/archive")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Void> archiveDocument(
            @PathVariable Long id,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        documentService.archiveDocument(id, userDetails.getId());
        return ResponseEntity.ok().build();
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @AuditLog(action = "DELETE_DOCUMENT", entityType = "DOCUMENT", details = "Deleted document")
    public ResponseEntity<Void> deleteDocument(@PathVariable Long id) {
        documentService.deleteDocument(id);
        return ResponseEntity.ok().build();
    }
}
