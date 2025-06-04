package com.mazraa.archive.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import lombok.Data;

@Data
public class DocumentCreateRequest {
    @NotBlank(message = "Title is required")
    private String title;

    private String barcode;

    private String description;

    @NotBlank(message = "Status is required")
    private String status;

    @NotNull(message = "Document type is required")
    private Long documentTypeId;

    private Long storageLocationId;
}
