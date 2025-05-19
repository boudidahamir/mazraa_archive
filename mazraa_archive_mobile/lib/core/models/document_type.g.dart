// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document_type.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DocumentType _$DocumentTypeFromJson(Map<String, dynamic> json) => DocumentType(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdById: (json['createdById'] as num?)?.toInt(),
      updatedById: (json['updatedById'] as num?)?.toInt(),
    );

Map<String, dynamic> _$DocumentTypeToJson(DocumentType instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'code': instance.code,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'createdById': instance.createdById,
      'updatedById': instance.updatedById,
    };
