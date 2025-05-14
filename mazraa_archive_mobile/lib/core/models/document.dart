import 'package:json_annotation/json_annotation.dart';

part 'document.g.dart';

@JsonSerializable()
class Document {
  final int? id;
  final String documentType;
  final String barcode;
  final String title;
  final String? description;
  final String status;
  final String? storageLocation;
  final String? filePath;
  final String? fileType;
  final int? fileSize;
  final bool archived;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? createdById;
  final int? updatedById;

  Document({
    this.id,
    required this.documentType,
    required this.barcode,
    required this.title,
    this.description,
    required this.status,
    this.storageLocation,
    this.filePath,
    this.fileType,
    this.fileSize,
    this.archived = false,
    required this.createdAt,
    this.updatedAt,
    this.createdById,
    this.updatedById,
  });

  factory Document.fromJson(Map<String, dynamic> json) => _$DocumentFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentToJson(this);

  Document copyWith({
    int? id,
    String? documentType,
    String? barcode,
    String? title,
    String? description,
    String? status,
    String? storageLocation,
    String? filePath,
    String? fileType,
    int? fileSize,
    bool? archived,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdById,
    int? updatedById,
  }) {
    return Document(
      id: id ?? this.id,
      documentType: documentType ?? this.documentType,
      barcode: barcode ?? this.barcode,
      title: title ?? this.title,
      description: description ?? this.description,
      status: status ?? this.status,
      storageLocation: storageLocation ?? this.storageLocation,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      archived: archived ?? this.archived,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdById: createdById ?? this.createdById,
      updatedById: updatedById ?? this.updatedById,
    );
  }
} 