package com.mazraa.archive.dto;

import com.mazraa.archive.model.StorageLocation;
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

    public static StorageLocationDTO toDTO(StorageLocation storageLocation) {
        StorageLocationDTO dto = new StorageLocationDTO();
        dto.setId(storageLocation.getId());
        dto.setCode(storageLocation.getCode());
        dto.setName(storageLocation.getName());
        dto.setDescription(storageLocation.getDescription());
        dto.setShelf(storageLocation.getShelf());
        dto.setRow(storageLocation.getRow());
        dto.setBox(storageLocation.getBox());
        dto.setActive(storageLocation.isActive());
        dto.setCapacity(storageLocation.getCapacity());
        dto.setUsedSpace(storageLocation.getUsedSpace());
        dto.setCreatedAt(storageLocation.getCreatedAt());
        dto.setUpdatedAt(storageLocation.getUpdatedAt());

        if (storageLocation.getCreatedBy() != null) {
            dto.setCreatedById(storageLocation.getCreatedBy().getId());
            dto.setCreatedByName(storageLocation.getCreatedBy().getFullName());
        }

        if (storageLocation.getUpdatedBy() != null) {
            dto.setUpdatedById(storageLocation.getUpdatedBy().getId());
            dto.setUpdatedByName(storageLocation.getUpdatedBy().getFullName());
        }

        return dto;
    }
}
