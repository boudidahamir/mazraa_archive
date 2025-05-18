package com.mazraa.archive.controller;

import com.mazraa.archive.annotation.AuditLog;
import com.mazraa.archive.service.BarcodeService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.io.IOException;

@RestController
@RequestMapping("/barcodes")
@RequiredArgsConstructor
@CrossOrigin(origins = "*")
@Tag(name = "Barcode Management", description = "APIs for managing document barcodes")
public class BarcodeController {

    private final BarcodeService barcodeService;

    @Operation(summary = "Generate a new barcode", description = "Generates a unique barcode for a document type")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Barcode generated successfully",
            content = @Content(schema = @Schema(implementation = String.class))),
        @ApiResponse(responseCode = "400", description = "Invalid document type"),
        @ApiResponse(responseCode = "401", description = "Unauthorized")
    })
    @PostMapping("/generate")
    @PreAuthorize("isAuthenticated()")
    @AuditLog(action = "GENERATE_BARCODE", entityType = "DOCUMENT", details = "Generated new barcode for document type: {documentType}")
    public ResponseEntity<String> generateBarcode(
            @Parameter(description = "Type of document (FACTURE, BON_LIVRAISON, etc.)") 
            @RequestParam String documentType,
            @Parameter(description = "Document ID") 
            @RequestParam Long id) {
        String prefix = barcodeService.getBarcodePrefix(documentType);
        String barcode = barcodeService.generateBarcode(prefix, id);
        return ResponseEntity.ok(barcode);
    }

    @Operation(summary = "Generate barcode image", description = "Generates a barcode image in PNG format")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Barcode image generated successfully",
            content = @Content(mediaType = MediaType.IMAGE_PNG_VALUE)),
        @ApiResponse(responseCode = "400", description = "Invalid barcode format"),
        @ApiResponse(responseCode = "401", description = "Unauthorized")
    })
    @GetMapping("/image/{barcode}")
    @PreAuthorize("isAuthenticated()")
    @AuditLog(action = "GENERATE_BARCODE_IMAGE", entityType = "DOCUMENT", details = "Generated barcode image for: {barcode}")
    public ResponseEntity<byte[]> generateBarcodeImage(
            @Parameter(description = "Barcode to generate image for") 
            @PathVariable String barcode) {
        try {
            if (!barcodeService.validateBarcode(barcode)) {
                return ResponseEntity.badRequest().build();
            }

            BufferedImage image = barcodeService.generateBarcodeImage(barcode);
            ByteArrayOutputStream outputStream = new ByteArrayOutputStream();
            ImageIO.write(image, "PNG", outputStream);
            byte[] imageBytes = outputStream.toByteArray();

            return ResponseEntity.ok()
                    .contentType(MediaType.IMAGE_PNG)
                    .body(imageBytes);
        } catch (IOException e) {
            return ResponseEntity.internalServerError().build();
        }
    }

    @Operation(summary = "Validate barcode", description = "Validates if a barcode is in the correct format")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Barcode validation result",
            content = @Content(schema = @Schema(implementation = Boolean.class))),
        @ApiResponse(responseCode = "401", description = "Unauthorized")
    })
    @GetMapping("/validate/{barcode}")
    @PreAuthorize("isAuthenticated()")
    @AuditLog(action = "VALIDATE_BARCODE", entityType = "DOCUMENT", details = "Validated barcode: {barcode}")
    public ResponseEntity<Boolean> validateBarcode(
            @Parameter(description = "Barcode to validate") 
            @PathVariable String barcode) {
        return ResponseEntity.ok(barcodeService.validateBarcode(barcode));
    }

    @Operation(summary = "Extract ID from barcode", description = "Extracts the document ID from a barcode")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "ID extracted successfully",
            content = @Content(schema = @Schema(implementation = String.class))),
        @ApiResponse(responseCode = "400", description = "Invalid barcode format"),
        @ApiResponse(responseCode = "401", description = "Unauthorized")
    })
    @GetMapping("/extract-id/{barcode}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<String> extractIdFromBarcode(
            @Parameter(description = "Barcode to extract ID from") 
            @PathVariable String barcode) {
        try {
            String id = barcodeService.extractIdFromBarcode(barcode);
            return ResponseEntity.ok(id);
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }

    @Operation(summary = "Associate barcode with location", description = "Associates a barcode with a storage location")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Barcode associated successfully"),
        @ApiResponse(responseCode = "400", description = "Invalid barcode or location"),
        @ApiResponse(responseCode = "401", description = "Unauthorized"),
        @ApiResponse(responseCode = "404", description = "Barcode or location not found")
    })
    @PostMapping("/{barcode}/location/{locationId}")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Void> associateBarcodeWithLocation(
            @Parameter(description = "Barcode to associate") 
            @PathVariable String barcode,
            @Parameter(description = "Storage location ID") 
            @PathVariable Long locationId) {
        barcodeService.associateBarcodeWithLocation(barcode, locationId);
        return ResponseEntity.ok().build();
    }

    @Operation(summary = "Get location for barcode", description = "Retrieves the storage location associated with a barcode")
    @ApiResponses(value = {
        @ApiResponse(responseCode = "200", description = "Location retrieved successfully",
            content = @Content(schema = @Schema(implementation = Long.class))),
        @ApiResponse(responseCode = "400", description = "Invalid barcode"),
        @ApiResponse(responseCode = "401", description = "Unauthorized"),
        @ApiResponse(responseCode = "404", description = "Barcode not found")
    })
    @GetMapping("/{barcode}/location")
    @PreAuthorize("isAuthenticated()")
    public ResponseEntity<Long> getLocationForBarcode(
            @Parameter(description = "Barcode to get location for") 
            @PathVariable String barcode) {
        Long locationId = barcodeService.getLocationIdForBarcode(barcode);
        return ResponseEntity.ok(locationId);
    }
} 