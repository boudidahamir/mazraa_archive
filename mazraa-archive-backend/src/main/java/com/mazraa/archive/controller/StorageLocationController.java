package com.mazraa.archive.controller;

import com.mazraa.archive.annotation.AuditLog;
import com.mazraa.archive.dto.StorageLocationCreateRequest;
import com.mazraa.archive.dto.StorageLocationDTO;
import com.mazraa.archive.dto.StorageLocationUpdateRequest;
import com.mazraa.archive.security.UserDetailsImpl;
import com.mazraa.archive.service.StorageLocationService;
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
@RequestMapping("/storage-locations")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class StorageLocationController {

    private final StorageLocationService storageLocationService;

    @GetMapping("/search")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Page<StorageLocationDTO>> searchStorageLocations(
            @RequestParam(required = false) String searchTerm,
            @RequestParam(required = false) String capacity,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            Pageable pageable) {
        return ResponseEntity.ok(storageLocationService.searchStorageLocations(searchTerm, capacity, startDate, endDate, pageable));
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<StorageLocationDTO>> getAllStorageLocations() {
        return ResponseEntity.ok(storageLocationService.getAllStorageLocations());
    }

    @PostMapping
    @PreAuthorize("hasRole('ADMIN')")
    @AuditLog(action = "CREATE_STORAGE_LOCATION", entityType = "STORAGE_LOCATION", details = "Created new storage location")
    public ResponseEntity<StorageLocationDTO> createStorageLocation(
            @Valid @RequestBody StorageLocationCreateRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        return ResponseEntity.ok(storageLocationService.createStorageLocation(request, userDetails.getId()));
    }

    @PutMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @AuditLog(action = "UPDATE_STORAGE_LOCATION", entityType = "STORAGE_LOCATION", details = "Updated storage location information")
    public ResponseEntity<StorageLocationDTO> updateStorageLocation(
            @PathVariable Long id,
            @Valid @RequestBody StorageLocationUpdateRequest request,
            @AuthenticationPrincipal UserDetailsImpl userDetails) {
        return ResponseEntity.ok(storageLocationService.updateStorageLocation(id, request, userDetails.getId()));
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<StorageLocationDTO> getStorageLocation(@PathVariable Long id) {
        return ResponseEntity.ok(storageLocationService.getStorageLocation(id));
    }

    @GetMapping("/code/{code}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<StorageLocationDTO> getStorageLocationByCode(@PathVariable String code) {
        return ResponseEntity.ok(storageLocationService.getStorageLocationByCode(code));
    }

    @GetMapping("/location")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<StorageLocationDTO> getStorageLocationByLocation(
            @RequestParam String shelf,
            @RequestParam String row,
            @RequestParam String box) {
        return ResponseEntity.ok(storageLocationService.getStorageLocationByLocation(shelf, row, box));
    }

    @GetMapping("/available")
    @PreAuthorize("hasAnyRole('ADMIN','USER')")
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