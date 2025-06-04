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
import jakarta.persistence.criteria.Expression;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.LocalTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class StorageLocationServiceImpl implements StorageLocationService {

    private final StorageLocationRepository storageLocationRepository;
    private final UserRepository userRepository;

    @Override
    @Transactional
    public StorageLocationDTO createStorageLocation(StorageLocationCreateRequest request, Long userId) {
        if (storageLocationRepository.existsByCode(request.getCode())) {
            throw new ResourceAlreadyExistsException(
                    "Storage location with code " + request.getCode() + " already exists");
        }

        if (storageLocationRepository.existsByName(request.getName())) {
            throw new ResourceAlreadyExistsException(
                    "Storage location with name " + request.getName() + " already exists");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        StorageLocation location = new StorageLocation();
        location.setName(request.getName());
        location.setCode(request.getCode());
        location.setDescription(request.getDescription());
        location.setShelf(request.getShelf());
        location.setRow(request.getRow());
        location.setBox(request.getBox());
        location.setCapacity(request.getCapacity());
        location.setUsedSpace(0L); // Initialize with 0
        location.setActive(true);
        location.setCreatedBy(user);
        location.setUpdatedBy(user);
        location.setCreatedAt(LocalDateTime.now());
        location.setUpdatedAt(LocalDateTime.now());

        return convertToDTO(storageLocationRepository.save(location));
    }

    @Override
    @Transactional
    public StorageLocationDTO updateStorageLocation(Long id, StorageLocationUpdateRequest request, Long userId) {
        StorageLocation location = storageLocationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Storage location not found"));

        if (!location.getName().equals(request.getName()) &&
                storageLocationRepository.existsByName(request.getName())) {
            throw new ResourceAlreadyExistsException(
                    "Storage location with name " + request.getName() + " already exists");
        }

        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found"));

        location.setName(request.getName());
        location.setDescription(request.getDescription());
        location.setShelf(request.getShelf());
        location.setRow(request.getRow());
        location.setBox(request.getBox());
        location.setCapacity(request.getCapacity());
        location.setActive(request.getActive());
        location.setUpdatedBy(user);
        location.setUpdatedAt(LocalDateTime.now());

        return convertToDTO(storageLocationRepository.save(location));
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
    public Page<StorageLocationDTO> searchStorageLocations(String searchTerm, String capacityFilter, LocalDate startDate, LocalDate endDate, Pageable pageable) {
        // If capacity filter is specified, use the dedicated repository methods
        if (capacityFilter != null && !capacityFilter.isEmpty()) {
            return switch (capacityFilter) {
                case "available" -> storageLocationRepository.findAvailableCapacityLocations(pageable).map(this::convertToDTO);
                case "nearFull" -> storageLocationRepository.findNearFullCapacityLocations(pageable).map(this::convertToDTO);
                case "full" -> storageLocationRepository.findFullCapacityLocations(pageable).map(this::convertToDTO);
                default -> searchStorageLocationsWithFilters(searchTerm, startDate, endDate, pageable);
            };
        }

        return searchStorageLocationsWithFilters(searchTerm, startDate, endDate, pageable);
    }

    private Page<StorageLocationDTO> searchStorageLocationsWithFilters(String searchTerm, LocalDate startDate, LocalDate endDate, Pageable pageable) {
        Specification<StorageLocation> spec = Specification.where(null);

        // Add search term filter
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            spec = spec.and((root, query, cb) -> {
                String pattern = "%" + searchTerm.toLowerCase() + "%";
                return cb.or(
                    cb.like(cb.lower(root.get("name")), pattern),
                    cb.like(cb.lower(root.get("code")), pattern),
                    cb.like(cb.lower(root.get("description")), pattern)
                );
            });
        }

        // Add date range filter
        if (startDate != null) {
            spec = spec.and((root, query, cb) ->
                cb.greaterThanOrEqualTo(root.get("createdAt"), startDate.atStartOfDay())
            );
        }
        if (endDate != null) {
            spec = spec.and((root, query, cb) ->
                cb.lessThanOrEqualTo(root.get("createdAt"), endDate.atTime(LocalTime.MAX))
            );
        }

        return storageLocationRepository.findAll(spec, pageable).map(this::convertToDTO);
    }

    @Override
    public Page<StorageLocationDTO> getAvailableStorageLocations(Pageable pageable) {
        return storageLocationRepository.findAvailableStorageLocations(pageable).map(this::convertToDTO);
    }

    @Override
    @Transactional
    public void deleteStorageLocation(Long id) {
        StorageLocation location = storageLocationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Storage location not found"));
        storageLocationRepository.delete(location);
    }

    @Override
    public List<StorageLocationDTO> getAllStorageLocations() {
        return storageLocationRepository.findAll().stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    private StorageLocationDTO convertToDTO(StorageLocation location) {
        StorageLocationDTO dto = new StorageLocationDTO();
        dto.setId(location.getId());
        dto.setName(location.getName());
        dto.setCode(location.getCode());
        dto.setDescription(location.getDescription());
        dto.setShelf(location.getShelf());
        dto.setRow(location.getRow());
        dto.setBox(location.getBox());
        dto.setActive(location.isActive());
        dto.setCapacity(location.getCapacity());
        dto.setUsedSpace(location.getUsedSpace());
        dto.setCreatedAt(location.getCreatedAt());
        dto.setUpdatedAt(location.getUpdatedAt());
    
        if (location.getCreatedBy() != null) {
            dto.setCreatedById(location.getCreatedBy().getId());
            dto.setCreatedByName(location.getCreatedBy().getFullName());
        }
    
        if (location.getUpdatedBy() != null) {
            dto.setUpdatedById(location.getUpdatedBy().getId());
            dto.setUpdatedByName(location.getUpdatedBy().getFullName());
        }
    
        return dto;
    }
} 