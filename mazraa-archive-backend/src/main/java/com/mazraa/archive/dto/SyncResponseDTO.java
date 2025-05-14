package com.mazraa.archive.dto;

import lombok.Data;

import java.util.List;
import java.util.Map;

@Data
public class SyncResponseDTO {
    private Map<String, Long> latestVersions;
    private List<SyncConflictDTO> conflicts;
} 