package com.mazraa.archive.repository;

import com.mazraa.archive.model.SyncLog;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@Repository
public interface SyncLogRepository extends JpaRepository<SyncLog, Long> {

    @Query("SELECT sl FROM SyncLog sl WHERE sl.deviceId = :deviceId AND sl.synced = false")
    Page<SyncLog> findPendingSyncs(@Param("deviceId") String deviceId, Pageable pageable);

    @Query("SELECT MAX(sl.serverVersion) FROM SyncLog sl WHERE sl.entityType = :entityType")
    Optional<Long> findLatestVersion(@Param("entityType") String entityType);
} 