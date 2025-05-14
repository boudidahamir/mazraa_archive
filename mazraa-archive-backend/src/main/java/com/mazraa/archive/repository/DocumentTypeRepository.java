package com.mazraa.archive.repository;

import com.mazraa.archive.model.DocumentType;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface DocumentTypeRepository extends JpaRepository<DocumentType, Long> {
    Optional<DocumentType> findByCode(String code);
    Optional<DocumentType> findByName(String name);
    boolean existsByCode(String code);
    boolean existsByName(String name);
} 