package com.mazraa.archive.controller;

import com.mazraa.archive.annotation.AuditLog;
import com.mazraa.archive.dto.SyncRequestDTO;
import com.mazraa.archive.dto.SyncResponseDTO;
import com.mazraa.archive.model.SyncLog;
import com.mazraa.archive.service.SyncService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/sync")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
@Tag(name = "Synchronization", description = "APIs for managing data synchronization between mobile and server")
public class SyncController {

    private final SyncService syncService;

    @Operation(summary = "Synchronize changes", description = "Synchronizes changes between mobile device and server")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Changes synchronized successfully",
            content = @Content(schema = @Schema(implementation = SyncResponseDTO.class))),
        @ApiResponse(responseCode = "400", description = "Invalid sync request"),
        @ApiResponse(responseCode = "401", description = "Unauthorized")
    })
    @PostMapping
    @PreAuthorize("isAuthenticated()")
    @AuditLog(action = "SYNC_CHANGES", entityType = "SYNC", details = "Synchronized changes with server")
    public ResponseEntity<SyncResponseDTO> syncChanges(
            @Parameter(description = "Sync request containing device ID and entity versions") 
            @RequestBody SyncRequestDTO request) {
        return ResponseEntity.ok(syncService.syncChanges(request));
    }

    @Operation(summary = "Get pending syncs", description = "Retrieves pending syncs for a device")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Pending syncs retrieved successfully",
            content = @Content(schema = @Schema(implementation = Page.class))),
        @ApiResponse(responseCode = "401", description = "Unauthorized")
    })
    @GetMapping("/pending/{deviceId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Page<SyncLog>> getPendingSyncs(
            @Parameter(description = "Device ID to get pending syncs for") 
            @PathVariable String deviceId,
            @Parameter(description = "Pagination parameters") 
            Pageable pageable) {
        return ResponseEntity.ok(syncService.getPendingSyncs(deviceId, pageable));
    }

    @Operation(summary = "Mark sync as completed", description = "Marks a sync log as completed")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Sync marked as completed"),
        @ApiResponse(responseCode = "401", description = "Unauthorized"),
        @ApiResponse(responseCode = "404", description = "Sync log not found")
    })
    @PostMapping("/{syncLogId}/mark-synced")
    @PreAuthorize("isAuthenticated()")
    @AuditLog(action = "MARK_SYNCED", entityType = "SYNC", details = "Marked sync as completed")
    public ResponseEntity<Void> markAsSynced(
            @Parameter(description = "ID of the sync log to mark as completed") 
            @PathVariable Long syncLogId) {
        syncService.markAsSynced(syncLogId);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Resolve sync conflict", description = "Resolves a sync conflict using the specified resolution strategy")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Conflict resolved successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid resolution strategy"),
        @ApiResponse(responseCode = "401", description = "Unauthorized"),
        @ApiResponse(responseCode = "404", description = "Sync log not found")
    })
    @PostMapping("/{syncLogId}/resolve-conflict")
    @PreAuthorize("isAuthenticated()")
    @AuditLog(action = "RESOLVE_CONFLICT", entityType = "SYNC", details = "Resolved sync conflict")
    public ResponseEntity<Void> resolveConflict(
            @Parameter(description = "ID of the sync log to resolve") 
            @PathVariable Long syncLogId,
            @Parameter(description = "Resolution strategy (SERVER, CLIENT, MERGE)") 
            @RequestParam String resolution) {
        syncService.handleConflict(syncLogId, resolution);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Get latest version", description = "Gets the latest version for an entity type")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Latest version retrieved successfully",
            content = @Content(schema = @Schema(implementation = Long.class))),
        @ApiResponse(responseCode = "401", description = "Unauthorized")
    })
    @GetMapping("/version/{entityType}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Long> getLatestVersion(
            @Parameter(description = "Entity type to get latest version for") 
            @PathVariable String entityType) {
        return ResponseEntity.ok(syncService.getLatestVersion(entityType));
    }
} 