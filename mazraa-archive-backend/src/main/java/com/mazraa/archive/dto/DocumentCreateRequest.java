package com.mazraa.archive.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class DocumentCreateRequest {
    @NotBlank(message = "Title is required")
    private String title;

    @NotBlank(message = "Barcode is required")
    private String barcode;

    private String description;

    @NotNull(message = "Document type is required")
    private Long documentTypeId;

    @NotNull(message = "Storage location is required")
    private Long storageLocationId;
} 