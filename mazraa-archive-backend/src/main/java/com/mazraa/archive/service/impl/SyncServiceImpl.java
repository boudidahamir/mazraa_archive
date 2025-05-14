package com.mazraa.archive.service.impl;

import com.mazraa.archive.dto.SyncRequestDTO;
import com.mazraa.archive.dto.SyncResponseDTO;
import com.mazraa.archive.dto.SyncChangeDTO;
import com.mazraa.archive.dto.SyncConflictDTO;
import com.mazraa.archive.exception.ResourceNotFoundException;
import com.mazraa.archive.model.SyncLog;
import com.mazraa.archive.repository.SyncLogRepository;
import com.mazraa.archive.service.SyncService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class SyncServiceImpl implements SyncService {

    private final SyncLogRepository syncLogRepository;
    private static final List<String> DOCUMENT_TYPES = List.of(
            "FACTURE", "BON_LIVRAISON", "ORDRE_PAIEMENT", "FICHE_PAIE"
    );

    @Override
    @Transactional
    public SyncResponseDTO syncChanges(SyncRequestDTO request) {
        // Validate document types
        validateDocumentTypes(request.getEntityVersions().keySet());

        // Get the latest version for each entity type
        Map<String, Long> latestVersions = request.getEntityVersions().entrySet().stream()
                .collect(Collectors.toMap(
                        Map.Entry::getKey,
                        entry -> getLatestVersion(entry.getKey())
                ));

        // Find conflicts
        List<SyncLog> allLogs = syncLogRepository.findAll();
        List<SyncLog> conflicts = allLogs.stream()
            .filter(log -> log.getDeviceId().equals(request.getDeviceId()))
            .filter(log -> request.getEntityVersions().containsKey(log.getEntityType()))
            .filter(log -> log.getServerVersion() != null &&
                log.getServerVersion() > request.getEntityVersions().getOrDefault(log.getEntityType(), 0L))
            .toList();

        // Process changes if any
        if (request.getChanges() != null && !request.getChanges().isEmpty()) {
            processChanges(request.getChanges());
        }

        // Create sync response
        SyncResponseDTO response = new SyncResponseDTO();
        response.setLatestVersions(latestVersions);
        response.setConflicts(conflicts.stream()
                .map(this::convertToConflictDTO)
                .collect(Collectors.toList()));

        return response;
    }

    @Override
    public Page<SyncLog> getPendingSyncs(String deviceId, Pageable pageable) {
        return syncLogRepository.findPendingSyncs(deviceId, pageable);
    }

    @Override
    @Transactional
    public void markAsSynced(Long syncLogId) {
        SyncLog syncLog = syncLogRepository.findById(syncLogId)
                .orElseThrow(() -> new ResourceNotFoundException("Sync log not found"));
        
        syncLog.setSynced(true);
        syncLog.setSyncedAt(LocalDateTime.now());
        syncLogRepository.save(syncLog);
    }

    @Override
    @Transactional
    public void handleConflict(Long syncLogId, String resolution) {
        SyncLog syncLog = syncLogRepository.findById(syncLogId)
                .orElseThrow(() -> new ResourceNotFoundException("Sync log not found"));

        // Apply the resolution based on the strategy
        switch (resolution.toUpperCase()) {
            case "SERVER":
                // Keep server version
                syncLog.setResolved(true);
                syncLog.setResolution("SERVER");
                break;
            case "CLIENT":
                // Keep client version
                syncLog.setResolved(true);
                syncLog.setResolution("CLIENT");
                break;
            case "MERGE":
                // Merge changes
                syncLog.setResolved(true);
                syncLog.setResolution("MERGE");
                // Implement merge logic here
                break;
            default:
                throw new IllegalArgumentException("Invalid resolution strategy");
        }

        syncLogRepository.save(syncLog);
    }

    @Override
    public Long getLatestVersion(String entityType) {
        return syncLogRepository.findLatestVersion(entityType)
                .orElse(0L);
    }

    private void validateDocumentTypes(java.util.Set<String> types) {
        if (!DOCUMENT_TYPES.containsAll(types)) {
            throw new IllegalArgumentException("Invalid document type(s) in sync request");
        }
    }

    private void processChanges(List<SyncChangeDTO> changes) {
        for (SyncChangeDTO change : changes) {
            SyncLog syncLog = new SyncLog();
            syncLog.setEntityType(change.getEntityType());
            syncLog.setEntityId(change.getEntityId());
            syncLog.setAction(change.getAction());
            syncLog.setClientData(change.getData());
            syncLog.setClientVersion(change.getVersion());
            syncLog.setDeviceId(change.getDeviceId());
            syncLog.setSynced(false);
            syncLog.setResolved(false);
            syncLogRepository.save(syncLog);
        }
    }

    private SyncConflictDTO convertToConflictDTO(SyncLog syncLog) {
        SyncConflictDTO dto = new SyncConflictDTO();
        dto.setSyncLogId(syncLog.getId());
        dto.setEntityType(syncLog.getEntityType());
        dto.setEntityId(syncLog.getEntityId());
        dto.setAction(syncLog.getAction());
        dto.setServerData(syncLog.getServerData());
        dto.setClientData(syncLog.getClientData());
        dto.setServerVersion(syncLog.getServerVersion());
        dto.setClientVersion(syncLog.getClientVersion());
        return dto;
    }
} 