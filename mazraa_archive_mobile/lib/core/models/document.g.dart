// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'document.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Document _$DocumentFromJson(Map<String, dynamic> json) => Document(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      barcode: json['barcode'] as String?,
      description: json['description'] as String?,
      status: json['status'] as String,
      documentTypeId: (json['documentTypeId'] as num).toInt(),
      documentTypeName: json['documentTypeName'] as String,
      storageLocationId: (json['storageLocationId'] as num?)?.toInt(),
      storageLocationCode: json['storageLocationCode'] as String?,
      archived: json['archived'] as bool,
      archivedAt: json['archivedAt'] == null
          ? null
          : DateTime.parse(json['archivedAt'] as String),
      archivedById: (json['archivedById'] as num?)?.toInt(),
      archivedByName: json['archivedByName'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      createdById: (json['createdById'] as num).toInt(),
      createdByName: json['createdByName'] as String,
      updatedById: (json['updatedById'] as num?)?.toInt(),
      updatedByName: json['updatedByName'] as String?,
    );

Map<String, dynamic> _$DocumentToJson(Document instance) => <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'barcode': instance.barcode,
      'description': instance.description,
      'status': instance.status,
      'documentTypeId': instance.documentTypeId,
      'documentTypeName': instance.documentTypeName,
      'storageLocationId': instance.storageLocationId,
      'storageLocationCode': instance.storageLocationCode,
      'archived': instance.archived,
      'archivedAt': instance.archivedAt?.toIso8601String(),
      'archivedById': instance.archivedById,
      'archivedByName': instance.archivedByName,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'createdById': instance.createdById,
      'createdByName': instance.createdByName,
      'updatedById': instance.updatedById,
      'updatedByName': instance.updatedByName,
    };
