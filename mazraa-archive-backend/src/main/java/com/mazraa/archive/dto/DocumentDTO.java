package com.mazraa.archive.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class DocumentDTO {
    private Long id;
    private String title;
    private String barcode;
    private String description;
    private Long documentTypeId;
    private String documentTypeName;
    private Long storageLocationId;
    private String storageLocationCode;
    private Long createdById;
    private String status;
    private String createdByName;
    private Long updatedById;
    private String updatedByName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private boolean archived;
    private LocalDateTime archivedAt;
    private Long archivedById;
    private String archivedByName;
}
