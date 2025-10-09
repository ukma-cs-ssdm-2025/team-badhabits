import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_entity.dart';

/// User model (data layer)
///
/// Extends [UserEntity] and adds methods for serialization/deserialization
/// of data for working with Firestore.
class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.email,
    required super.name,
    required super.userType,
    super.bio,
    super.avatarUrl,
    required super.createdAt,
  });

  /// Creates [UserModel] from [UserEntity]
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      email: entity.email,
      name: entity.name,
      userType: entity.userType,
      bio: entity.bio,
      avatarUrl: entity.avatarUrl,
      createdAt: entity.createdAt,
    );
  }

  /// Creates [UserModel] from JSON (Map)
  ///
  /// Used for deserializing data from Firestore
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      userType: _userTypeFromString(json['userType'] as String),
      bio: json['bio'] as String?,
      avatarUrl: json['avatarUrl'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }

  /// Creates [UserModel] from Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel.fromJson({
      'id': doc.id,
      ...data,
    });
  }

  /// Converts [UserModel] to JSON (Map)
  ///
  /// Used for serializing data before saving to Firestore
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'userType': _userTypeToString(userType),
      'bio': bio,
      'avatarUrl': avatarUrl,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Converts [UserModel] to Map for Firestore (without id)
  ///
  /// ID is usually stored as the document key, so it's not included in the data
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    json.remove('id');
    return json;
  }

  /// Converts enum [UserType] to String for storage
  static String _userTypeToString(UserType userType) {
    switch (userType) {
      case UserType.regularUser:
        return 'regularUser';
      case UserType.trainer:
        return 'trainer';
    }
  }

  /// Converts String to enum [UserType]
  static UserType _userTypeFromString(String userTypeString) {
    switch (userTypeString) {
      case 'regularUser':
        return UserType.regularUser;
      case 'trainer':
        return UserType.trainer;
      default:
        throw ArgumentError('Invalid userType: $userTypeString');
    }
  }

  /// Copies the model with the ability to change individual fields
  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    UserType? userType,
    String? bio,
    String? avatarUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      userType: userType ?? this.userType,
      bio: bio ?? this.bio,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
