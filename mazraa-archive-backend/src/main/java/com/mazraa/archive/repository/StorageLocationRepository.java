package com.mazraa.archive.repository;

import com.mazraa.archive.model.StorageLocation;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface StorageLocationRepository extends JpaRepository<StorageLocation, Long> {
    Optional<StorageLocation> findByCode(String code);
    boolean existsByCode(String code);

    @Query("SELECT sl FROM StorageLocation sl WHERE " +
           "LOWER(sl.name) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
           "LOWER(sl.description) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
           "LOWER(sl.code) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    Optional<StorageLocation> searchByTerm(@Param("searchTerm") String searchTerm);

    @Query("SELECT sl FROM StorageLocation sl WHERE " +
           "sl.shelf = :shelf AND sl.row = :row AND sl.box = :box")
    Optional<StorageLocation> findByLocation(@Param("shelf") String shelf,
                                           @Param("row") String row,
                                           @Param("box") String box);

    @Query("SELECT sl FROM StorageLocation sl WHERE sl.active = true AND sl.usedSpace < sl.capacity")
    Page<StorageLocation> findAvailableStorageLocations(Pageable pageable);
} 