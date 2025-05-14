package com.mazraa.archive.dto;

import lombok.Data;

import java.time.LocalDateTime;

@Data
public class DocumentTypeDTO {
    private Long id;
    private String name;
    private String description;
    private String code;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private Long createdById;
    private String createdByName;
    private Long updatedById;
    private String updatedByName;
} 