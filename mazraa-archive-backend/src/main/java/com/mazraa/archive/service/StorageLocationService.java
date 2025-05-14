package com.mazraa.archive.service;

import com.mazraa.archive.dto.StorageLocationCreateRequest;
import com.mazraa.archive.dto.StorageLocationDTO;
import com.mazraa.archive.dto.StorageLocationUpdateRequest;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface StorageLocationService {
    StorageLocationDTO createStorageLocation(StorageLocationCreateRequest request, Long userId);
    StorageLocationDTO updateStorageLocation(Long id, StorageLocationUpdateRequest request, Long userId);
    StorageLocationDTO getStorageLocation(Long id);
    StorageLocationDTO getStorageLocationByCode(String code);
    StorageLocationDTO getStorageLocationByLocation(String shelf, String row, String box);
    Page<StorageLocationDTO> searchStorageLocations(String searchTerm, Pageable pageable);
    Page<StorageLocationDTO> getAvailableStorageLocations(Pageable pageable);
    void deleteStorageLocation(Long id);
} 