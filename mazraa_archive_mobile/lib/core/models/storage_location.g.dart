// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_location.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StorageLocation _$StorageLocationFromJson(Map<String, dynamic> json) =>
    StorageLocation(
      id: (json['id'] as num?)?.toInt(),
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      shelf: json['shelf'] as String,
      row: json['row'] as String,
      box: json['box'] as String,
      capacity: (json['capacity'] as num).toInt(),
      usedSpace: (json['usedSpace'] as num?)?.toInt() ?? 0,
      active: json['active'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] == null
          ? null
          : User.fromJson(json['createdBy'] as Map<String, dynamic>),
      updatedBy: json['updatedBy'] == null
          ? null
          : User.fromJson(json['updatedBy'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$StorageLocationToJson(StorageLocation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'code': instance.code,
      'name': instance.name,
      'description': instance.description,
      'shelf': instance.shelf,
      'row': instance.row,
      'box': instance.box,
      'capacity': instance.capacity,
      'usedSpace': instance.usedSpace,
      'active': instance.active,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'createdBy': instance.createdBy,
      'updatedBy': instance.updatedBy,
    };
