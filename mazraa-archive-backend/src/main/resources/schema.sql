-- Create database if not exists
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'mazraa_archive')
BEGIN
    CREATE DATABASE mazraa_archive;
END
GO

USE mazraa_archive;
GO

-- Users table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'users')
BEGIN
    CREATE TABLE users (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        email VARCHAR(255) NOT NULL UNIQUE,
        password VARCHAR(255) NOT NULL,
        roles VARCHAR(255) NOT NULL,
        is_active BIT NOT NULL DEFAULT 1,
        created_at DATETIME NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME NOT NULL DEFAULT GETDATE()
    );
END
GO

-- Document types table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'document_types')
BEGIN
    CREATE TABLE document_types (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        code VARCHAR(50) NOT NULL UNIQUE,
        description TEXT,
        is_active BIT NOT NULL DEFAULT 1,
        created_at DATETIME NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME NOT NULL DEFAULT GETDATE()
    );
END
GO

-- Storage locations table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'storage_locations')
BEGIN
    CREATE TABLE storage_locations (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        code VARCHAR(50) NOT NULL UNIQUE,
        capacity INT NOT NULL,
        description TEXT,
        is_active BIT NOT NULL DEFAULT 1,
        created_at DATETIME NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME NOT NULL DEFAULT GETDATE()
    );
END
GO

-- Documents table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'documents')
BEGIN
    CREATE TABLE documents (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        title VARCHAR(255) NOT NULL,
        barcode VARCHAR(100) NOT NULL UNIQUE,
        document_type_id BIGINT NOT NULL,
        storage_location_id BIGINT,
        status VARCHAR(50) NOT NULL,
        description TEXT,
        created_at DATETIME NOT NULL DEFAULT GETDATE(),
        updated_at DATETIME NOT NULL DEFAULT GETDATE(),
        archived_at DATETIME,
        FOREIGN KEY (document_type_id) REFERENCES document_types(id),
        FOREIGN KEY (storage_location_id) REFERENCES storage_locations(id)
    );
END
GO

-- Audit logs table
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'audit_logs')
BEGIN
    CREATE TABLE audit_logs (
        id BIGINT IDENTITY(1,1) PRIMARY KEY,
        user_id BIGINT NOT NULL,
        action VARCHAR(50) NOT NULL,
        entity_type VARCHAR(50) NOT NULL,
        entity_id BIGINT NOT NULL,
        details TEXT,
        created_at DATETIME NOT NULL DEFAULT GETDATE(),
        FOREIGN KEY (user_id) REFERENCES users(id)
    );
END
GO

-- Insert default document types
IF NOT EXISTS (SELECT * FROM document_types WHERE code = 'INVOICE')
BEGIN
    INSERT INTO document_types (name, code, description) VALUES
    ('Facture', 'INVOICE', 'Factures clients et fournisseurs'),
    ('Bon de livraison', 'DELIVERY_NOTE', 'Bons de livraison'),
    ('Ordre de paiement', 'PAYMENT_ORDER', 'Ordres de paiement'),
    ('Fiche de paie', 'PAYSLIP', 'Fiches de paie des employés');
END
GO

-- Create indexes
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_documents_barcode')
BEGIN
    CREATE INDEX idx_documents_barcode ON documents(barcode);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_documents_status')
BEGIN
    CREATE INDEX idx_documents_status ON documents(status);
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'idx_audit_logs_created_at')
BEGIN
    CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
END
GO 