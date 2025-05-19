import 'package:json_annotation/json_annotation.dart';
import 'package:mazraa_archive_mobile/core/models/document_type.dart';

part 'generated_barcode.g.dart';

@JsonSerializable()
class GeneratedBarcode {
  final String barcode;
  final DocumentType documentType;
  final DateTime generatedAt;
  final bool isUsed;
  final String? documentId;
  final String? storageLocation;

  GeneratedBarcode({
    required this.barcode,
    required this.documentType,
    required this.generatedAt,
    this.isUsed = false,
    this.documentId,
    this.storageLocation,
  });

  factory GeneratedBarcode.fromJson(Map<String, dynamic> json) =>
      _$GeneratedBarcodeFromJson(json);

  Map<String, dynamic> toJson() => _$GeneratedBarcodeToJson(this);

  GeneratedBarcode copyWith({
    String? barcode,
    DocumentType? documentType,
    DateTime? generatedAt,
    bool? isUsed,
    String? documentId,
    String? storageLocation,
  }) {
    return GeneratedBarcode(
      barcode: barcode ?? this.barcode,
      documentType: documentType ?? this.documentType,
      generatedAt: generatedAt ?? this.generatedAt,
      isUsed: isUsed ?? this.isUsed,
      documentId: documentId ?? this.documentId,
      storageLocation: storageLocation ?? this.storageLocation,
    );
  }
} 