package com.mazraa.archive.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;
import lombok.Data;

@Data
public class StorageLocationUpdateRequest {
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

    @NotNull(message = "Active status is required")
    private Boolean active;

    @NotNull(message = "Used space is required")
    @Positive(message = "Used space must be zero or positive")
    private Long usedSpace;
} 