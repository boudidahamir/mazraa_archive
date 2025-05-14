package com.mazraa.archive.service.impl;

import com.mazraa.archive.dto.StorageLocationCreateRequest;
import com.mazraa.archive.dto.StorageLocationDTO;
import com.mazraa.archive.dto.StorageLocationUpdateRequest;
import com.mazraa.archive.exception.ResourceAlreadyExistsException;
import com.mazraa.archive.exception.ResourceNotFoundException;
import com.mazraa.archive.model.StorageLocation;
import com.mazraa.archive.model.User;
import com.mazraa.archive.repository.StorageLocationRepository;
import com.mazraa.archive.repository.UserRepository;
import com.mazraa.archive.service.StorageLocationService;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
@RequiredArgsConstructor
public class StorageLocationServiceImpl implements StorageLocationService {

    private final StorageLocationRepository storageLocationRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public StorageLocationDTO createStorageLocation(StorageLocationCreateRequest request, Long userId) {
        if (storageLocationRepository.existsByCode(request.getCode())) {
            throw new ResourceAlreadyExistsException("Storage location with code " + request.getCode() + " already exists");
        }

        if (storageLocationRepository.findByLocation(request.getShelf(), request.getRow(), request.getBox()).isPresent()) {
            throw new ResourceAlreadyExistsException("Storage location with shelf " + request.getShelf() + 
                ", row " + request.getRow() + ", and box " + request.getBox() + " already exists");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        StorageLocation storageLocation = new StorageLocation();
        storageLocation.setCode(request.getCode());
        storageLocation.setName(request.getName());
        storageLocation.setDescription(request.getDescription());
        storageLocation.setShelf(request.getShelf());
        storageLocation.setRow(request.getRow());
        storageLocation.setBox(request.getBox());
        storageLocation.setCapacity(request.getCapacity());
        storageLocation.setUsedSpace(0L);
        storageLocation.setActive(true);
        storageLocation.setCreatedBy(user);

        return convertToDTO(storageLocationRepository.save(storageLocation));
    }

    @Override
    @Transactional
    public StorageLocationDTO updateStorageLocation(Long id, StorageLocationUpdateRequest request, Long userId) {
        StorageLocation storageLocation = storageLocationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Storage location not found"));

        if (!storageLocation.getShelf().equals(request.getShelf()) || 
            !storageLocation.getRow().equals(request.getRow()) || 
            !storageLocation.getBox().equals(request.getBox())) {
            
            if (storageLocationRepository.findByLocation(request.getShelf(), request.getRow(), request.getBox()).isPresent()) {
                throw new ResourceAlreadyExistsException("Storage location with shelf " + request.getShelf() + 
                    ", row " + request.getRow() + ", and box " + request.getBox() + " already exists");
            }
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        storageLocation.setName(request.getName());
        storageLocation.setDescription(request.getDescription());
        storageLocation.setShelf(request.getShelf());
        storageLocation.setRow(request.getRow());
        storageLocation.setBox(request.getBox());
        storageLocation.setCapacity(request.getCapacity());
        storageLocation.setActive(request.getActive());
        storageLocation.setUpdatedBy(user);

        return convertToDTO(storageLocationRepository.save(storageLocation));
    }

    @Override
    public StorageLocationDTO getStorageLocation(Long id) {
        return convertToDTO(storageLocationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Storage location not found")));
    }

    @Override
    public StorageLocationDTO getStorageLocationByCode(String code) {
        return convertToDTO(storageLocationRepository.findByCode(code)
                .orElseThrow(() -> new ResourceNotFoundException("Storage location not found")));
    }

    @Override
    public StorageLocationDTO getStorageLocationByLocation(String shelf, String row, String box) {
        return convertToDTO(storageLocationRepository.findByLocation(shelf, row, box)
                .orElseThrow(() -> new ResourceNotFoundException("Storage location not found")));
    }

    @Override
    public Page<StorageLocationDTO> searchStorageLocations(String searchTerm, Pageable pageable) {
        return storageLocationRepository.findAll(pageable)
                .map(this::convertToDTO);
    }

    @Override
    public Page<StorageLocationDTO> getAvailableStorageLocations(Pageable pageable) {
        return storageLocationRepository.findAvailableStorageLocations(pageable)
                .map(this::convertToDTO);
    }

    @Override
    @Transactional
    public void deleteStorageLocation(Long id) {
        StorageLocation storageLocation = storageLocationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Storage location not found"));
        storageLocationRepository.delete(storageLocation);
    }

    private StorageLocationDTO convertToDTO(StorageLocation storageLocation) {
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
        dto.setCreatedById(storageLocation.getCreatedBy().getId());
        dto.setCreatedByName(storageLocation.getCreatedBy().getFullName());
        if (storageLocation.getUpdatedBy() != null) {
            dto.setUpdatedById(storageLocation.getUpdatedBy().getId());
            dto.setUpdatedByName(storageLocation.getUpdatedBy().getFullName());
        }
        return dto;
    }
} 