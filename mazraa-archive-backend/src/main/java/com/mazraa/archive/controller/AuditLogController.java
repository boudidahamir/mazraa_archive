package com.mazraa.archive.controller;

import com.mazraa.archive.dto.AuditLogDTO;
import com.mazraa.archive.service.AuditLogService;
import lombok.RequiredArgsConstructor;

import java.time.LocalDate;
import java.util.List;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/audit-logs")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
public class AuditLogController {

    private final AuditLogService auditLogService;

    @GetMapping("/search")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Page<AuditLogDTO>> searchAuditLogs(
            @RequestParam(required = false) String searchTerm,
            @RequestParam(required = false) String action,
            @RequestParam(required = false) String entityType,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate startDate,
            @RequestParam(required = false) @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate endDate,
            Pageable pageable) {
        return ResponseEntity.ok(auditLogService.searchAuditLogs(searchTerm, action, entityType, startDate, endDate, pageable));
    }

    @GetMapping
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<List<AuditLogDTO>> getAllAuditLogs() {
        return ResponseEntity.ok(auditLogService.getAllAuditLogs());
    }

    @GetMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<AuditLogDTO> getAuditLog(@PathVariable Long id) {
        return ResponseEntity.ok(auditLogService.getAuditLog(id));
    }

    @GetMapping("/entity/{entityType}/{entityId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Page<AuditLogDTO>> getAuditLogsForEntity(
            @PathVariable String entityType,
            @PathVariable Long entityId,
            Pageable pageable) {
        return ResponseEntity.ok(auditLogService.getAuditLogsForEntity(entityType, entityId, pageable));
    }

    @GetMapping("/user/{userId}")
    @PreAuthorize("hasRole('ADMIN')")
    public ResponseEntity<Page<AuditLogDTO>> getAuditLogsForUser(
            @PathVariable Long userId,
            Pageable pageable) {
        return ResponseEntity.ok(auditLogService.getAuditLogsForUser(userId, pageable));
    }
} 