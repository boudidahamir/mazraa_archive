package com.mazraa.archive.service.impl;

import com.google.zxing.BarcodeFormat;
import com.google.zxing.client.j2se.MatrixToImageWriter;
import com.google.zxing.common.BitMatrix;
import com.google.zxing.oned.Code128Writer;
import com.mazraa.archive.service.BarcodeService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.awt.image.BufferedImage;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
@RequiredArgsConstructor
public class BarcodeServiceImpl implements BarcodeService {

    private static final Map<String, String> DOCUMENT_TYPE_PREFIXES = new HashMap<>();
    private static final String SEPARATOR = "-";
    private static final Map<String, Long> BARCODE_LOCATION_MAP = new ConcurrentHashMap<>();

    static {
        DOCUMENT_TYPE_PREFIXES.put("FACTURE", "F");
        DOCUMENT_TYPE_PREFIXES.put("BON_LIVRAISON", "BL");
        DOCUMENT_TYPE_PREFIXES.put("ORDRE_PAIEMENT", "OP");
        DOCUMENT_TYPE_PREFIXES.put("FICHE_PAIE", "FP");
    }

    @Override
    public String generateBarcode(String prefix, Long id) {
        return prefix + SEPARATOR + String.format("%08d", id);
    }

    @Override
    public BufferedImage generateBarcodeImage(String barcode) {
        try {
            Code128Writer writer = new Code128Writer();
            BitMatrix bitMatrix = writer.encode(barcode, BarcodeFormat.CODE_128, 300, 100);
            return MatrixToImageWriter.toBufferedImage(bitMatrix);
        } catch (Exception e) {
            throw new RuntimeException("Error generating barcode image", e);
        }
    }

    @Override
    public boolean validateBarcode(String barcode) {
        if (barcode == null || barcode.isEmpty()) {
            return false;
        }

        String[] parts = barcode.split(SEPARATOR);
        if (parts.length != 2) {
            return false;
        }

        String prefix = parts[0];
        String id = parts[1];

        // Validate prefix
        if (!DOCUMENT_TYPE_PREFIXES.containsValue(prefix)) {
            return false;
        }

        // Validate ID format
        try {
            Long.parseLong(id);
            return true;
        } catch (NumberFormatException e) {
            return false;
        }
    }

    @Override
    public String extractIdFromBarcode(String barcode) {
        if (!validateBarcode(barcode)) {
            throw new IllegalArgumentException("Invalid barcode format");
        }
        return barcode.split(SEPARATOR)[1];
    }

    @Override
    public String getBarcodePrefix(String documentType) {
        String prefix = DOCUMENT_TYPE_PREFIXES.get(documentType);
        if (prefix == null) {
            throw new IllegalArgumentException("Invalid document type: " + documentType);
        }
        return prefix;
    }

    @Override
    public void associateBarcodeWithLocation(String barcode, Long locationId) {
        if (!validateBarcode(barcode)) {
            throw new IllegalArgumentException("Invalid barcode format");
        }
        BARCODE_LOCATION_MAP.put(barcode, locationId);
    }

    @Override
    public Long getLocationIdForBarcode(String barcode) {
        if (!validateBarcode(barcode)) {
            throw new IllegalArgumentException("Invalid barcode format");
        }
        return BARCODE_LOCATION_MAP.get(barcode);
    }
} 