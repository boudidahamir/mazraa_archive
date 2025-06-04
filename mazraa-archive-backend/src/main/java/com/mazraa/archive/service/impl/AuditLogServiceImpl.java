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
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class AuditLogServiceImpl implements AuditLogService {

    private final AuditLogRepository auditLogRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public void log(String action, String entityType, Long entityId, Long userId, String details, String ipAddress) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        AuditLog log = new AuditLog();
        log.setAction(action);
        log.setEntityType(entityType);
        log.setEntityId(entityId);
        log.setDetails(details);
        log.setIpAddress(ipAddress);
        log.setUser(user);

        auditLogRepository.save(log);
    }

    @Override
    public AuditLogDTO getAuditLog(Long id) {
        return convertToDTO(auditLogRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Audit log not found")));
    }

    @Override
    public Page<AuditLogDTO> searchAuditLogs(String searchTerm, String action, String entityType, LocalDate startDate, LocalDate endDate, Pageable pageable) {
        Specification<AuditLog> spec = Specification.where(null);

        // Add search term filter
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            spec = spec.and((root, query, cb) -> {
                String pattern = "%" + searchTerm.toLowerCase() + "%";
                return cb.or(
                    cb.like(cb.lower(root.get("user").get("username")), pattern),
                    cb.like(cb.lower(root.get("details")), pattern),
                    cb.like(cb.lower(root.get("ipAddress")), pattern)
                );
            });
        }

        // Add action filter
        if (action != null && !action.isEmpty()) {
            spec = spec.and((root, query, cb) ->
                cb.equal(root.get("action"), action)
            );
        }

        // Add entity type filter
        if (entityType != null && !entityType.isEmpty()) {
            spec = spec.and((root, query, cb) ->
                cb.equal(root.get("entityType"), entityType)
            );
        }

        // Add date range filter
        if (startDate != null) {
            spec = spec.and((root, query, cb) ->
                cb.greaterThanOrEqualTo(root.get("createdAt"), startDate.atStartOfDay())
            );
        }
        if (endDate != null) {
            spec = spec.and((root, query, cb) ->
                cb.lessThanOrEqualTo(root.get("createdAt"), endDate.atTime(LocalTime.MAX))
            );
        }

        // Add join fetch to avoid N+1 queries
        spec = spec.and((root, query, cb) -> {
            if (Long.class != query.getResultType()) {
                root.fetch("user");
            }
            return cb.conjunction();
        });

        return auditLogRepository.findAll(spec, pageable).map(this::convertToDTO);
    }

    @Override
    public Page<AuditLogDTO> getAuditLogsForEntity(String entityType, Long entityId, Pageable pageable) {
        return auditLogRepository.findByEntityTypeAndEntityId(entityType, entityId, pageable)
                .map(this::convertToDTO);
    }

    @Override
    public Page<AuditLogDTO> getAuditLogsForUser(Long userId, Pageable pageable) {
        return auditLogRepository.findByUserId(userId, pageable)
                .map(this::convertToDTO);
    }

    @Override
    public List<AuditLogDTO> getAllAuditLogs() {
        return auditLogRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    private AuditLogDTO convertToDTO(AuditLog log) {
        AuditLogDTO dto = new AuditLogDTO();
        dto.setId(log.getId());
        dto.setAction(log.getAction());
        dto.setEntityType(log.getEntityType());
        dto.setEntityId(log.getEntityId());
        dto.setDetails(log.getDetails());
        dto.setIpAddress(log.getIpAddress());
        dto.setCreatedAt(log.getCreatedAt());
        
        if (log.getUser() != null) {
            dto.setUserId(log.getUser().getId());
            dto.setUsername(log.getUser().getUsername());
            dto.setUserFullName(log.getUser().getFullName());
        }
        
        return dto;
    }
} 