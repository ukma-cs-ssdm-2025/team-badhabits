import 'dart:developer' as developer;
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
      // Validate userId
      if (userId.isEmpty) {
        throw Exception('Invalid user ID');
      }

      // Build update data
      final updateData = <String, dynamic>{};
      if (name != null && name.trim().isNotEmpty) {
        updateData['name'] = name.trim();
      }
      if (bio != null) {
        updateData['bio'] = bio.trim();
      }
      if (avatarUrl != null) {
        updateData['avatarUrl'] = avatarUrl;
      }

      if (updateData.isEmpty) {
        throw Exception('No fields to update');
      }

      // Add server timestamp
      updateData['updatedAt'] = FieldValue.serverTimestamp();

      developer.log('Updating profile for user $userId', name: 'profile.datasource');

      // Update user profile in Firestore
      final docRef = firestore.collection('users').doc(userId);
      await docRef.update(updateData);

      // Read the updated document to get the actual data with server timestamp
      final updatedSnapshot = await docRef.get();

      if (!updatedSnapshot.exists) {
        throw Exception('User not found after update');
      }

      return UserModel.fromFirestore(updatedSnapshot);
    } catch (e) {
      developer.log(
        'Failed to update user profile: $e',
        name: 'profile.datasource',
        level: 1000,
      );
      throw Exception('Failed to update user profile: $e');
    }
  }

  @override
  Future<String> uploadAvatar({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // Get current user data to check for existing avatar
      final userDoc = await firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data();
        final oldAvatarUrl = userData?['avatarUrl'] as String?;

        // Delete old avatar if it exists
        if (oldAvatarUrl != null && oldAvatarUrl.isNotEmpty) {
          try {
            // Extract storage path from URL
            final uri = Uri.parse(oldAvatarUrl);
            // URL format: https://firebasestorage.googleapis.com/v0/b/{bucket}/o/{path}?alt=media&token={token}
            final pathSegments = uri.pathSegments;
            if (pathSegments.length >= 4 && pathSegments[2] == 'o') {
              // Decode the path (it's URL encoded)
              final encodedPath = pathSegments[3];
              final storagePath = Uri.decodeComponent(encodedPath);

              // Delete the old file
              final oldRef = storage.ref().child(storagePath);
              await oldRef.delete();
              developer.log(
                'Deleted old avatar: $storagePath',
                name: 'profile.datasource',
              );
            }
          } catch (e) {
            // Don't fail upload if deletion fails
            developer.log(
              'Failed to delete old avatar: $e',
              name: 'profile.datasource',
              level: 900,
            );
          }
        }
      }

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
