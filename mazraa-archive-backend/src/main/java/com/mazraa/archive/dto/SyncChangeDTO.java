package com.mazraa.archive.dto;

import lombok.Data;

@Data
public class SyncChangeDTO {
    private String entityType;
    private Long entityId;
    private String action;
    private String data;
    private Long version;
    private String deviceId;
} 