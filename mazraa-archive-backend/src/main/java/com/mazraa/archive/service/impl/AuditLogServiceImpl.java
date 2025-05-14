package com.mazraa.archive.service.impl;

import com.mazraa.archive.dto.AuditLogDTO;
import com.mazraa.archive.exception.ResourceNotFoundException;
import com.mazraa.archive.model.AuditLog;
import com.mazraa.archive.model.User;
import com.mazraa.archive.repository.AuditLogRepository;
import com.mazraa.archive.repository.UserRepository;
import com.mazraa.archive.service.AuditLogService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class AuditLogServiceImpl implements AuditLogService {

    private final AuditLogRepository auditLogRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public void logAction(String action, String entityType, Long entityId, String details, String ipAddress, Long userId) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        AuditLog auditLog = new AuditLog();
        auditLog.setAction(action);
        auditLog.setEntityType(entityType);
        auditLog.setEntityId(entityId);
        auditLog.setDetails(details);
        auditLog.setIpAddress(ipAddress);
        auditLog.setUser(user);

        auditLogRepository.save(auditLog);
    }

    @Override
    public Page<AuditLogDTO> getAuditLogsByEntity(String entityType, Long entityId, Pageable pageable) {
        return auditLogRepository.findByEntityTypeAndEntityId(entityType, entityId, pageable)
                .map(this::convertToDTO);
    }

    @Override
    public Page<AuditLogDTO> getAuditLogsByUser(Long userId, Pageable pageable) {
        return auditLogRepository.findByUserId(userId, pageable)
                .map(this::convertToDTO);
    }

    @Override
    public Page<AuditLogDTO> getAuditLogsByAction(String action, Pageable pageable) {
        return auditLogRepository.findByAction(action, pageable)
                .map(this::convertToDTO);
    }

    @Override
    public Page<AuditLogDTO> getAllAuditLogs(Pageable pageable) {
        return auditLogRepository.findAll(pageable)
                .map(this::convertToDTO);
    }

    private AuditLogDTO convertToDTO(AuditLog auditLog) {
        AuditLogDTO dto = new AuditLogDTO();
        dto.setId(auditLog.getId());
        dto.setAction(auditLog.getAction());
        dto.setEntityType(auditLog.getEntityType());
        dto.setEntityId(auditLog.getEntityId());
        dto.setDetails(auditLog.getDetails());
        dto.setIpAddress(auditLog.getIpAddress());
        dto.setUserId(auditLog.getUser().getId());
        dto.setUsername(auditLog.getUser().getUsername());
        dto.setUserFullName(auditLog.getUser().getFullName());
        dto.setCreatedAt(auditLog.getCreatedAt());
        return dto;
    }
} 