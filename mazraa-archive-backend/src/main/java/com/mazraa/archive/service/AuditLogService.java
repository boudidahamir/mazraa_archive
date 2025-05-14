package com.mazraa.archive.service;

import com.mazraa.archive.dto.AuditLogDTO;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface AuditLogService {
    void logAction(String action, String entityType, Long entityId, String details, String ipAddress, Long userId);
    Page<AuditLogDTO> getAuditLogsByEntity(String entityType, Long entityId, Pageable pageable);
    Page<AuditLogDTO> getAuditLogsByUser(Long userId, Pageable pageable);
    Page<AuditLogDTO> getAuditLogsByAction(String action, Pageable pageable);
    Page<AuditLogDTO> getAllAuditLogs(Pageable pageable);
} 