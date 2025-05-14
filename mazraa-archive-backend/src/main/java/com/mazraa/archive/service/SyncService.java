package com.mazraa.archive.service;

import com.mazraa.archive.dto.SyncRequestDTO;
import com.mazraa.archive.dto.SyncResponseDTO;
import com.mazraa.archive.model.SyncLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface SyncService {
    SyncResponseDTO syncChanges(SyncRequestDTO request);
    Page<SyncLog> getPendingSyncs(String deviceId, Pageable pageable);
    void markAsSynced(Long syncLogId);
    void handleConflict(Long syncLogId, String resolution);
    Long getLatestVersion(String entityType);
} 