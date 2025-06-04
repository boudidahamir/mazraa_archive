package com.mazraa.archive.repository;

import com.mazraa.archive.model.Document;
import com.mazraa.archive.model.DocumentType;

import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface DocumentRepository extends JpaRepository<Document, Long>, JpaSpecificationExecutor<Document> {
    Optional<Document> findByBarcode(String barcode);
    boolean existsByBarcode(String barcode);

    @Query("SELECT d FROM Document d WHERE " +
           "LOWER(d.title) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
           "LOWER(d.description) LIKE LOWER(CONCAT('%', :searchTerm, '%')) OR " +
           "LOWER(d.barcode) LIKE LOWER(CONCAT('%', :searchTerm, '%'))")
    Page<Document> searchDocuments(@Param("searchTerm") String searchTerm, Pageable pageable);

    
    Page<Document> findByDocumentTypeId(Long documentTypeId, Pageable pageable);
    Page<Document> findByStorageLocationId(Long storageLocationId, Pageable pageable);
    Page<Document> findByCreatedById(Long userId, Pageable pageable);
    Page<Document> findByArchived(boolean archived, Pageable pageable);
    List<Document> findByDocumentType(DocumentType type);
} 