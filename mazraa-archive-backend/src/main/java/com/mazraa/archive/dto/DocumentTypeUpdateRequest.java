package com.mazraa.archive.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import lombok.Data;

@Data
public class DocumentTypeUpdateRequest {
    @NotBlank(message = "Name is required")
    private String name;
    @NotBlank(message = "Code is required")
    @Pattern(regexp = "^[A-Z0-9_]+$", message = "Code must contain only uppercase letters, numbers, and underscores")
    private String code;
    private String description;
} 