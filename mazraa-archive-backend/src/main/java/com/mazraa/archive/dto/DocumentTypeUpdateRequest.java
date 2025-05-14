package com.mazraa.archive.dto;

import jakarta.validation.constraints.NotBlank;
import lombok.Data;

@Data
public class DocumentTypeUpdateRequest {
    @NotBlank(message = "Name is required")
    private String name;

    private String description;
} 