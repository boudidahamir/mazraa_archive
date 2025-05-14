import 'package:json_annotation/json_annotation.dart';

part 'storage_location.g.dart';

@JsonSerializable()
class StorageLocation {
  final int? id;
  final String code;
  final String name;
  final String? description;
  final String? shelf;
  final String? row;
  final String? box;
  final int capacity;
  final int usedSpace;
  final bool active;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? createdById;
  final int? updatedById;

  StorageLocation({
    this.id,
    required this.code,
    required this.name,
    this.description,
    this.shelf,
    this.row,
    this.box,
    required this.capacity,
    this.usedSpace = 0,
    this.active = true,
    required this.createdAt,
    this.updatedAt,
    this.createdById,
    this.updatedById,
  });

  factory StorageLocation.fromJson(Map<String, dynamic> json) => _$StorageLocationFromJson(json);
  Map<String, dynamic> toJson() => _$StorageLocationToJson(this);

  StorageLocation copyWith({
    int? id,
    String? code,
    String? name,
    String? description,
    String? shelf,
    String? row,
    String? box,
    int? capacity,
    int? usedSpace,
    bool? active,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdById,
    int? updatedById,
  }) {
    return StorageLocation(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      shelf: shelf ?? this.shelf,
      row: row ?? this.row,
      box: box ?? this.box,
      capacity: capacity ?? this.capacity,
      usedSpace: usedSpace ?? this.usedSpace,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdById: createdById ?? this.createdById,
      updatedById: updatedById ?? this.updatedById,
    );
  }

  bool get hasAvailableSpace => usedSpace < capacity;
  int get availableSpace => capacity - usedSpace;
} 