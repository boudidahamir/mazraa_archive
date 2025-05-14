package com.mazraa.archive.model;

import lombok.Data;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import jakarta.persistence.*;
import java.time.LocalDateTime;

@Data
@Entity
@Table(name = "sync_logs")
public class SyncLog {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String deviceId;

    @Column(nullable = false)
    private String entityType;

    @Column(nullable = false)
    private Long entityId;

    @Column(nullable = false)
    private String action;

    @Column(columnDefinition = "TEXT")
    private String serverData;

    @Column(columnDefinition = "TEXT")
    private String clientData;

    @Column(nullable = false)
    private Long serverVersion;

    @Column(nullable = false)
    private Long clientVersion;

    @Column(nullable = false)
    private boolean synced = false;

    @Column
    private LocalDateTime syncedAt;

    @Column(nullable = false)
    private boolean resolved = false;

    @Column
    private String resolution;

    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;
} 