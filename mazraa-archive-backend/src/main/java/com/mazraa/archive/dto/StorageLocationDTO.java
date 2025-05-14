package com.mazraa.archive.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class StorageLocationDTO {
    private Long id;
    private String code;
    private String name;
    private String description;
    private String shelf;
    private String row;
    private String box;
    private boolean active;
    private Long capacity;
    private Long usedSpace;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Long createdById;
    private String createdByName;
    private Long updatedById;
    private String updatedByName;
} 