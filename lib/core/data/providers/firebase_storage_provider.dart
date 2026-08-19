import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/core/data/services/firebase_storage_service.dart';

final firebaseStorageServiceProvider = Provider<FirebaseStorageService>((ref) {
  return FirebaseStorageService();
});
