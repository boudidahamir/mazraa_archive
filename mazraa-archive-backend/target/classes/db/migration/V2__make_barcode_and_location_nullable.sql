-- Rendre la colonne barcode nullable
ALTER TABLE documents ALTER COLUMN barcode VARCHAR(255) NULL;

-- Rendre la colonne storage_location_id nullable
ALTER TABLE documents ALTER COLUMN storage_location_id BIGINT NULL;

ALTER TABLE [dbo].[documents] DROP CONSTRAINT [UQ__document__C16E36F8B8D12186];

CREATE UNIQUE INDEX idx_unique_barcode_not_null ON [dbo].[documents]([barcode]) WHERE [barcode] IS NOT NULL;
