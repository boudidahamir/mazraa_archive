import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

enum UserRole {
  @JsonValue('ADMIN')
  admin,
  @JsonValue('USER')
  user
}

@JsonSerializable()
class User {
  final int? id;
  final String username;
  final String email;
  final String fullName;
  final UserRole role;
  final bool enabled;
  final String? deviceId;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? createdById;
  final int? updatedById;
  final bool? isActive;
  final String? roles;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    this.enabled = true,
    this.deviceId,
    required this.createdAt,
    this.updatedAt,
    this.createdById,
    this.updatedById,
    this.isActive,
    this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['fullName'],
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      enabled: json['enabled'] ?? true,
      deviceId: json['deviceId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdById: json['createdById'],
      updatedById: json['updatedById'],
      isActive: json['isActive'] ?? true,
      roles: json['roles'] ?? 'ROLE_${json['role']}',
    );
  }

  // Method to create User from SQLite data (flattened structure)
  factory User.fromSqlite(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['fullName'],
      role: $enumDecode(_$UserRoleEnumMap, json['role']),
      enabled: json['enabled'] == 1,
      deviceId: json['deviceId'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
      createdById: json['createdById'],
      updatedById: json['updatedById'],
      isActive: json['isActive'] == 1,
      roles: json['roles'],
    );
  }

  Map<String, dynamic> toJson() => _$UserToJson(this);

  bool get isAdmin => role == UserRole.admin;
}
