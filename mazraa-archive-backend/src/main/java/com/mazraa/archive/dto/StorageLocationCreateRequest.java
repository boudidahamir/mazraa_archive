package com.mazraa.archive.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
public class StorageLocationCreateRequest {
    @NotBlank(message = "Code is required")
    @Pattern(regexp = "^[A-Z0-9_]+$", message = "Code must contain only uppercase letters, numbers, and underscores")
    private String code;

    @NotBlank(message = "Name is required")
    private String name;

    private String description;

    @NotBlank(message = "Shelf is required")
    private String shelf;

    @NotBlank(message = "Row is required")
    private String row;

    @NotBlank(message = "Box is required")
    private String box;

    @NotNull(message = "Capacity is required")
    @Positive(message = "Capacity must be positive")
    private Long capacity;
} 