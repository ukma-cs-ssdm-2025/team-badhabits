import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../auth/data/models/user_model.dart';

/// Remote data source for profile operations
///
/// Handles direct communication with Firestore and Firebase Storage
abstract class ProfileRemoteDataSource {
  /// Get user profile from Firestore
  Future<UserModel> getUserProfile(String userId);

  /// Update user profile in Firestore
  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? bio,
    String? avatarUrl,
  });

  /// Upload avatar image to Firebase Storage
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  });
}

/// Implementation of [ProfileRemoteDataSource]
class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  ProfileRemoteDataSourceImpl({required this.firestore, required this.storage});
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  @override
  Future<UserModel> getUserProfile(String userId) async {
    try {
      final userDoc = await firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }

      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  @override
  Future<UserModel> updateUserProfile({
    required String userId,
    String? name,
    String? bio,
    String? avatarUrl,
  }) async {
    try {
      // Build update data
      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (bio != null) updateData['bio'] = bio;
      if (avatarUrl != null) updateData['avatarUrl'] = avatarUrl;

      if (updateData.isEmpty) {
        throw Exception('No fields to update');
      }

      // Update in Firestore
      await firestore.collection('users').doc(userId).update(updateData);

      // Get updated user
      final userDoc = await firestore.collection('users').doc(userId).get();
      return UserModel.fromFirestore(userDoc);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Create reference to storage location
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = storage.ref().child('avatars/$userId/$fileName');

      // Upload file
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload avatar: $e');
    }
  }
}
