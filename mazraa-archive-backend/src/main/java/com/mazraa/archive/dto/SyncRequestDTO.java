package com.mazraa.archive.dto;

import lombok.Data;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotEmpty;
import java.util.List;
import java.util.Map;

@Data
public class SyncRequestDTO {
    @NotBlank(message = "Device ID is required")
    private String deviceId;

    @NotEmpty(message = "Entity versions are required")
    private Map<String, Long> entityVersions;

    private List<SyncChangeDTO> changes;
} 