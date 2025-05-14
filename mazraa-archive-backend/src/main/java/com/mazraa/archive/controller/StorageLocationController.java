package com.mazraa.archive.controller;

import com.mazraa.archive.annotation.AuditLog;
import com.mazraa.archive.dto.StorageLocationCreateRequest;
import com.mazraa.archive.dto.StorageLocationDTO;
import com.mazraa.archive.dto.StorageLocationUpdateRequest;
import com.mazraa.archive.security.CustomUserDetails;
import com.mazraa.archive.service.StorageLocationService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/storage-locations")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class StorageLocationController {

    private final StorageLocationService storageLocationService;

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @AuditLog(action = "CREATE_STORAGE_LOCATION", entityType = "STORAGE_LOCATION", details = "Created new storage location")
    public ResponseEntity<StorageLocationDTO> createStorageLocation(
            @Valid @RequestBody StorageLocationCreateRequest request,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(storageLocationService.createStorageLocation(request, userDetails.getId()));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @AuditLog(action = "UPDATE_STORAGE_LOCATION", entityType = "STORAGE_LOCATION", details = "Updated storage location information")
    public ResponseEntity<StorageLocationDTO> updateStorageLocation(
            @PathVariable Long id,
            @Valid @RequestBody StorageLocationUpdateRequest request,
            @AuthenticationPrincipal CustomUserDetails userDetails) {
        return ResponseEntity.ok(storageLocationService.updateStorageLocation(id, request, userDetails.getId()));
    }

    @GetMapping("/{id}")
    @PreAuthorize("isAuthenticated()")
    @AuditLog(action = "VIEW_STORAGE_LOCATION", entityType = "STORAGE_LOCATION", details = "Viewed storage location details")
    public ResponseEntity<StorageLocationDTO> getStorageLocation(@PathVariable Long id) {
        return ResponseEntity.ok(storageLocationService.getStorageLocation(id));
    }

    @GetMapping("/code/{code}")
    @PreAuthorize("isAuthenticated()")
    @AuditLog(action = "VIEW_STORAGE_LOCATION", entityType = "STORAGE_LOCATION", details = "Viewed storage location by code")
    public ResponseEntity<StorageLocationDTO> getStorageLocationByCode(@PathVariable String code) {
        return ResponseEntity.ok(storageLocationService.getStorageLocationByCode(code));
    }

    @GetMapping("/location")
    @PreAuthorize("isAuthenticated()")
    @AuditLog(action = "VIEW_STORAGE_LOCATION", entityType = "STORAGE_LOCATION", details = "Viewed storage location by physical location")
    public ResponseEntity<StorageLocationDTO> getStorageLocationByLocation(
            @RequestParam String shelf,
            @RequestParam String row,
            @RequestParam String box) {
        return ResponseEntity.ok(storageLocationService.getStorageLocationByLocation(shelf, row, box));
    }

    @GetMapping("/search")
    @PreAuthorize("isAuthenticated()")
    @AuditLog(action = "SEARCH_STORAGE_LOCATIONS", entityType = "STORAGE_LOCATION", details = "Searched storage locations")
    public ResponseEntity<Page<StorageLocationDTO>> searchStorageLocations(
            @RequestParam String searchTerm,
            Pageable pageable) {
        return ResponseEntity.ok(storageLocationService.searchStorageLocations(searchTerm, pageable));
    }

    @GetMapping("/available")
    @PreAuthorize("isAuthenticated()")
    @AuditLog(action = "VIEW_AVAILABLE_STORAGE_LOCATIONS", entityType = "STORAGE_LOCATION", details = "Viewed available storage locations")
    public ResponseEntity<Page<StorageLocationDTO>> getAvailableStorageLocations(Pageable pageable) {
        return ResponseEntity.ok(storageLocationService.getAvailableStorageLocations(pageable));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @AuditLog(action = "DELETE_STORAGE_LOCATION", entityType = "STORAGE_LOCATION", details = "Deleted storage location")
    public ResponseEntity<Void> deleteStorageLocation(@PathVariable Long id) {
        storageLocationService.deleteStorageLocation(id);
        return ResponseEntity.ok().build();
    }
} 