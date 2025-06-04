-- Rendre la colonne barcode nullable
ALTER TABLE documents ALTER COLUMN barcode VARCHAR(255) NULL;

-- Rendre la colonne storage_location_id nullable
ALTER TABLE documents ALTER COLUMN storage_location_id BIGINT NULL;
