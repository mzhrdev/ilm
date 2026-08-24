// Current User Info Provider
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/auth/data/model/user_model.dart';
import 'package:lms/features/auth/data/providers/auth_provider.dart';

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});