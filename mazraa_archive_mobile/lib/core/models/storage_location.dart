import 'package:json_annotation/json_annotation.dart';
import 'user.dart';

part 'storage_location.g.dart';

@JsonSerializable()
class StorageLocation {
  final int? id;
  final String code;
  final String name;
  final String? description;
  final String shelf;
  final String row;
  final String box;
  final int capacity;
  final int usedSpace;
  final bool active;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final User? createdBy;
  final User? updatedBy;

  StorageLocation({
    this.id,
    required this.code,
    required this.name,
    this.description,
    required this.shelf,
    required this.row,
    required this.box,
    required this.capacity,
    this.usedSpace = 0,
    this.active = true,
    required this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory StorageLocation.fromJson(Map<String, dynamic> json) =>
      _$StorageLocationFromJson(json);
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
    User? createdBy,
    User? updatedBy,
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
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
  Map<String, dynamic> toSqliteMap({String syncStatus = 'synced'}) {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'shelf': shelf,
      'row': row,
      'box': box,
      'capacity': capacity,
      'usedSpace': usedSpace,
      'active': active ? 1 : 0,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'createdById': createdBy?.id,
      'updatedById': updatedBy?.id,
      'sync_status': syncStatus,
    };
  }

  factory StorageLocation.fromSqlite(Map<String, dynamic> map) {
    return StorageLocation(
      id: map['id'],
      code: map['code'],
      name: map['name'],
      description: map['description'],
      shelf: map['shelf'],
      row: map['row'],
      box: map['box'],
      capacity: map['capacity'],
      usedSpace: map['usedSpace'] ?? 0,
      active: map['active'] == 1, // 🔥 SQLite uses 0/1 for bool
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      createdBy: null, // You can populate if needed
      updatedBy: null,
    );
  }

  bool get hasAvailableSpace => usedSpace < capacity;
  int get availableSpace => capacity - usedSpace;
}
