package com.mazraa.archive.service;

import com.mazraa.archive.dto.AuditLogDTO;
import java.time.LocalDate;
import java.util.List;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface AuditLogService {
    void log(String action, String entityType, Long entityId, Long userId, String details, String ipAddress);
    AuditLogDTO getAuditLog(Long id);
    Page<AuditLogDTO> searchAuditLogs(String searchTerm, String action, String entityType, LocalDate startDate, LocalDate endDate, Pageable pageable);
    Page<AuditLogDTO> getAuditLogsForEntity(String entityType, Long entityId, Pageable pageable);
    Page<AuditLogDTO> getAuditLogsForUser(Long userId, Pageable pageable);
    List<AuditLogDTO> getAllAuditLogs();
} 