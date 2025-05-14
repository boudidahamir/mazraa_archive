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
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? fullName,
    UserRole? role,
    bool? enabled,
    String? deviceId,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? createdById,
    int? updatedById,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      enabled: enabled ?? this.enabled,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdById: createdById ?? this.createdById,
      updatedById: updatedById ?? this.updatedById,
    );
  }

  bool get isAdmin => role == UserRole.admin;
} 