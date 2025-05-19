import 'package:json_annotation/json_annotation.dart';

import 'document_type.dart';

part 'document.g.dart';
// Re-trigger build_runner

@JsonSerializable()
class Document {
  final int id;
  final String title;
  final String barcode;
  final String? description;
  final String status;

  final int documentTypeId;
  final String documentTypeName;

  final int storageLocationId;
  final String storageLocationCode;

  final bool archived;
  final DateTime? archivedAt;

  final int? archivedById;
  final String? archivedByName;

  final DateTime createdAt;
  final DateTime? updatedAt;

  final int createdById;
  final String createdByName;

  final int? updatedById;
  final String? updatedByName;

  Document({
    required this.id,
    required this.title,
    required this.barcode,
    this.description,
    required this.status,
    required this.documentTypeId,
    required this.documentTypeName,
    required this.storageLocationId,
    required this.storageLocationCode,
    required this.archived,
    this.archivedAt,
    this.archivedById,
    this.archivedByName,
    required this.createdAt,
    this.updatedAt,
    required this.createdById,
    required this.createdByName,
    this.updatedById,
    this.updatedByName,
  });
  Document copyWith({
    int? id,
    String? title,
    String? barcode,
    String? description,
    String? status,
    int? documentTypeId,
    String? documentTypeName,
    int? storageLocationId,
    String? storageLocationCode,
    bool? archived,
    DateTime? archivedAt,
    int? archivedById,
    String? archivedByName,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdById,
    String? createdByName,
    int? updatedById,
    String? updatedByName,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      barcode: barcode ?? this.barcode,
      description: description ?? this.description,
      status: status ?? this.status,
      documentTypeId: documentTypeId ?? this.documentTypeId,
      documentTypeName: documentTypeName ?? this.documentTypeName,
      storageLocationId: storageLocationId ?? this.storageLocationId,
      storageLocationCode: storageLocationCode ?? this.storageLocationCode,
      archived: archived ?? this.archived,
      archivedAt: archivedAt ?? this.archivedAt,
      archivedById: archivedById ?? this.archivedById,
      archivedByName: archivedByName ?? this.archivedByName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdById: createdById ?? this.createdById,
      createdByName: createdByName ?? this.createdByName,
      updatedById: updatedById ?? this.updatedById,
      updatedByName: updatedByName ?? this.updatedByName,
    );
  }

  factory Document.fromJson(Map<String, dynamic> json) =>
      _$DocumentFromJson(json);

  Map<String, dynamic> toJson() => _$DocumentToJson(this);
}
