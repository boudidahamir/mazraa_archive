package com.mazraa.archive.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class AuditLogDTO {
    private Long id;
    private String action;
    private String entityType;
    private Long entityId;
    private String details;
    private String ipAddress;
    private Long userId;
    private String username;
    private String userFullName;
    private LocalDateTime createdAt;
} 