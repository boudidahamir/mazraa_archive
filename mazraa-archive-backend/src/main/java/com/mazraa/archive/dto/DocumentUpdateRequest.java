package com.mazraa.archive.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class DocumentUpdateRequest {
    @NotBlank(message = "Title is required")
    private String title;

    private String description;

    @NotNull(message = "Document type is required")
    private Long documentTypeId;

    @NotNull(message = "Storage location is required")
    private Long storageLocationId;
} 