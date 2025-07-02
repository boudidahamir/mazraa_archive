// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'generated_barcode.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

import 'package:mazraa_archive_mobile/core/models/document_type.dart';

import 'generated_barcode.dart';

GeneratedBarcode _$GeneratedBarcodeFromJson(Map<String, dynamic> json) =>
    GeneratedBarcode(
      barcode: json['barcode'] as String,
      documentType:
          DocumentType.fromJson(json['documentType'] as Map<String, dynamic>),
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      isUsed: json['isUsed'] as bool? ?? false,
      documentId: json['documentId'] as String?,
      storageLocation: json['storageLocation'] as String?,
    );

Map<String, dynamic> _$GeneratedBarcodeToJson(GeneratedBarcode instance) =>
    <String, dynamic>{
      'barcode': instance.barcode,
      'documentType': instance.documentType,
      'generatedAt': instance.generatedAt.toIso8601String(),
      'isUsed': instance.isUsed,
      'documentId': instance.documentId,
      'storageLocation': instance.storageLocation,
    };
