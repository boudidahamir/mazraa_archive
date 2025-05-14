package com.mazraa.archive.service;

import java.awt.image.BufferedImage;

public interface BarcodeService {
    String generateBarcode(String prefix, Long id);
    BufferedImage generateBarcodeImage(String barcode);
    boolean validateBarcode(String barcode);
    String extractIdFromBarcode(String barcode);
    String getBarcodePrefix(String documentType);
    void associateBarcodeWithLocation(String barcode, Long locationId);
    Long getLocationIdForBarcode(String barcode);
} 