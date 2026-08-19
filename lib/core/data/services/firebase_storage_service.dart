import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  FirebaseStorageService({FirebaseStorage? storage}) : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  /// Uploads a user's profile image and returns its download URL.
  Future<String> uploadProfileImage({required String userId, required File imageFile}) async {
    try {
      final storageRef = _storage.ref().child('profile_images/$userId.jpg');

      final uploadTask = await storageRef.putFile(imageFile, SettableMetadata(contentType: 'image/jpeg'));

      return await uploadTask.ref.getDownloadURL();
    } on FirebaseException catch (e) {
      throw Exception('Failed to upload profile image: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while uploading profile image: $e');
    }
  }

  /// Deletes the user's profile image from Firebase Storage.
  Future<void> deleteProfileImage(String userId) async {
    try {
      final storageRef = _storage.ref().child('profile_images/$userId.jpg');

      await storageRef.delete();
    } on FirebaseException catch (e) {
      // If the file doesn't exist, there is nothing to delete.
      if (e.code == 'object-not-found') return;

      throw Exception('Failed to delete profile image: ${e.message}');
    } catch (e) {
      throw Exception('Unexpected error while deleting profile image: $e');
    }
  }
}
