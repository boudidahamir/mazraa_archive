class GeneratedBarcode {
  final String barcode;
  final String documentType; // This should be the documentType code (e.g., "INVOICE")
  final DateTime generatedAt;
  final bool isUsed;
  final int documentId;
  final String storageLocation;

  GeneratedBarcode({
    required this.barcode,
    required this.documentType,
    required this.generatedAt,
    this.isUsed = false,
    required this.documentId,
    required this.storageLocation,
  });

  Map<String, dynamic> toJson() {
    return {
      'barcode': barcode,
      'document_type': documentType,
      'generated_at': generatedAt.toIso8601String(),
      'is_used': isUsed ? 1 : 0,
      'document_id': documentId,
      'storage_location': storageLocation,
    };
  }

  factory GeneratedBarcode.fromJson(Map<String, dynamic> json) {
    return GeneratedBarcode(
      barcode: json['barcode'],
      documentType: json['document_type'],
      generatedAt: DateTime.parse(json['generated_at']),
      isUsed: json['is_used'] == 1,
      documentId: json['document_id'],
      storageLocation: json['storage_location'],
    );
  }
}
