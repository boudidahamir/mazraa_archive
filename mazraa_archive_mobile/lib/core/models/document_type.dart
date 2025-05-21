import 'package:json_annotation/json_annotation.dart';

part 'document_type.g.dart';

@JsonSerializable()
class DocumentType {
  final int id;
  final String name;
  final String code;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int? createdById;
  final int? updatedById;

  DocumentType({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.createdAt,
    required this.updatedAt,
    this.createdById,
    this.updatedById,
  });

  factory DocumentType.fromSqlite(Map<String, dynamic> map) {
    return DocumentType(
      id: map['id'],
      name: map['name'],
      code: map['code'],
      description: map['description'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      createdById: map['created_by_id'],
      updatedById: map['updated_by_id'],
    );
  }

  factory DocumentType.fromJson(Map<String, dynamic> json) => _$DocumentTypeFromJson(json);
  Map<String, dynamic> toJson() => _$DocumentTypeToJson(this);
}
