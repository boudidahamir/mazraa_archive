package com.mazraa.archive.controller;

import com.mazraa.archive.annotation.AuditLog;
import com.mazraa.archive.dto.DocumentCreateRequest;
import com.mazraa.archive.dto.DocumentDTO;
import com.mazraa.archive.dto.DocumentUpdateRequest;
import com.mazraa.archive.security.CustomUserDetails;
import com.mazraa.archive.service.DocumentService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("/api/documents")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class DocumentController {

    private final DocumentService documentService;

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @AuditLog(action = "CREATE_DOCUMENT", entityType = "DOCUMENT", details = "Created new document")
    public ResponseEntity<DocumentDTO> createDocument(
            @Valid @RequestBody DocumentCreateRequest request,
            @RequestParam("file") MultipartFile file,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(documentService.createDocument(request, file, userDetails.getId()));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @AuditLog(action = "UPDATE_DOCUMENT", entityType = "DOCUMENT", details = "Updated document information")
    public ResponseEntity<DocumentDTO> updateDocument(
            @PathVariable Long id,
            @Valid @RequestBody DocumentUpdateRequest request,
            @RequestParam(value = "file", required = false) MultipartFile file,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(documentService.updateDocument(id, request, file, userDetails.getId()));
    }

    @GetMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    @AuditLog(action = "VIEW_DOCUMENT", entityType = "DOCUMENT", details = "Viewed document details")
    public ResponseEntity<DocumentDTO> getDocument(@PathVariable Long id) {
        return ResponseEntity.ok(documentService.getDocument(id));
    }

    @GetMapping("/barcode/{barcode}")
    @PreAuthorize("isAuthenticated()")
    @AuditLog(action = "VIEW_DOCUMENT", entityType = "DOCUMENT", details = "Viewed document by barcode")
    public ResponseEntity<DocumentDTO> getDocumentByBarcode(@PathVariable String barcode) {
        return ResponseEntity.ok(documentService.getDocumentByBarcode(barcode));
    }

    @GetMapping("/search")
    @PreAuthorize("isAuthenticated()")
    @AuditLog(action = "SEARCH_DOCUMENTS", entityType = "DOCUMENT", details = "Searched documents")
    public ResponseEntity<Page<DocumentDTO>> searchDocuments(
            @RequestParam String searchTerm,
            Pageable pageable) {
        return ResponseEntity.ok(documentService.searchDocuments(searchTerm, pageable));
    }

    @GetMapping("/type/{documentTypeId}")
    @PreAuthorize("isAuthenticated()")
    @AuditLog(action = "VIEW_DOCUMENTS_BY_TYPE", entityType = "DOCUMENT", details = "Viewed documents by type")
    public ResponseEntity<Page<DocumentDTO>> getDocumentsByType(
            @PathVariable Long documentTypeId,
            Pageable pageable) {
        return ResponseEntity.ok(documentService.getDocumentsByType(documentTypeId, pageable));
    }

    @GetMapping("/location/{storageLocationId}")
    @PreAuthorize("isAuthenticated()")
    @AuditLog(action = "VIEW_DOCUMENTS_BY_LOCATION", entityType = "DOCUMENT", details = "Viewed documents by location")
    public ResponseEntity<Page<DocumentDTO>> getDocumentsByLocation(
            @PathVariable Long storageLocationId,
            Pageable pageable) {
        return ResponseEntity.ok(documentService.getDocumentsByLocation(storageLocationId, pageable));
    }

    @GetMapping("/user/{userId}")
    @PreAuthorize("isAuthenticated()")
    @AuditLog(action = "VIEW_DOCUMENTS_BY_USER", entityType = "DOCUMENT", details = "Viewed documents by user")
    public ResponseEntity<Page<DocumentDTO>> getDocumentsByUser(
            @PathVariable Long userId,
            Pageable pageable) {
        return ResponseEntity.ok(documentService.getDocumentsByUser(userId, pageable));
    }

    @GetMapping("/archived")
    @PreAuthorize("isAuthenticated()")
    @AuditLog(action = "VIEW_ARCHIVED_DOCUMENTS", entityType = "DOCUMENT", details = "Viewed archived documents")
    public ResponseEntity<Page<DocumentDTO>> getArchivedDocuments(
            @RequestParam boolean archived,
            Pageable pageable) {
        return ResponseEntity.ok(documentService.getArchivedDocuments(archived, pageable));
    }

    @PostMapping("/{id}/archive")
    @PreAuthorize("hasRole('ADMIN')")
    @AuditLog(action = "ARCHIVE_DOCUMENT", entityType = "DOCUMENT", details = "Archived document")
    public ResponseEntity<Void> archiveDocument(
            @PathVariable Long id,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
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

    @GetMapping("/{id}/download")
    @PreAuthorize("isAuthenticated()")
    @AuditLog(action = "DOWNLOAD_DOCUMENT", entityType = "DOCUMENT", details = "Downloaded document file")
    public ResponseEntity<Resource> downloadDocument(@PathVariable Long id) {
        byte[] fileContent = documentService.downloadDocument(id);
        ByteArrayResource resource = new ByteArrayResource(fileContent);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"" + id + "\"")
                .contentType(MediaType.APPLICATION_OCTET_STREAM)
                .contentLength(fileContent.length)
                .body(resource);
    }
} 