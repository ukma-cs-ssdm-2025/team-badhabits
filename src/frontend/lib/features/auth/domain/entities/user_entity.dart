import 'package:equatable/equatable.dart';

/// Enum for user type
enum UserType { regularUser, trainer }

/// User entity (domain layer)
///
/// Represents basic user information in the system.
/// Independent of data sources and used in business logic.
class UserEntity extends Equatable {
  const UserEntity({
    required this.id,
    required this.email,
    required this.name,
    required this.userType,
    required this.createdAt,
    this.bio,
    this.avatarUrl,
  });

  /// Unique user identifier
  final String id;

  /// User email address
  final String email;

  /// User name
  final String name;

  /// User type (regular user or trainer)
  final UserType userType;

  /// User biography (optional)
  final String? bio;

  /// User avatar URL (optional)
  final String? avatarUrl;

  /// Account creation date
  final DateTime createdAt;

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    userType,
    bio,
    avatarUrl,
    createdAt,
  ];

  /// Copies the entity with the ability to change individual fields
  UserEntity copyWith({
    String? id,
    String? email,
    String? name,
    UserType? userType,
    String? bio,
    String? avatarUrl,
    DateTime? createdAt,
  }) => UserEntity(
    id: id ?? this.id,
    email: email ?? this.email,
    name: name ?? this.name,
    userType: userType ?? this.userType,
    bio: bio ?? this.bio,
    avatarUrl: avatarUrl ?? this.avatarUrl,
    createdAt: createdAt ?? this.createdAt,
  );
}
