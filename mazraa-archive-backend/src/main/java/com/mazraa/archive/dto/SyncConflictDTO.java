package com.mazraa.archive.dto;

import lombok.Data;

@Data
public class SyncConflictDTO {
    private Long syncLogId;
    private String entityType;
    private Long entityId;
    private String action;
    private String serverData;
    private String clientData;
    private Long serverVersion;
    private Long clientVersion;
} 