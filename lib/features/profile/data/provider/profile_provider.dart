import 'package:Edvance/core/data/services/firebase_firestore_services.dart';
import 'package:Edvance/features/auth/data/model/user_model.dart';
import 'package:Edvance/features/auth/data/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final firestoreServices = ref.watch(firestoreServicesProvider);
  return ProfileNotifier(firestoreServices);
});

class ProfileState {
  const ProfileState({this.userProfile, this.isLoading = false, this.error});

  final UserModel? userProfile;
  final bool isLoading;
  final String? error;

  static const Object _unset = Object();

  ProfileState copyWith({UserModel? userProfile, bool? isLoading, Object? error = _unset}) {
    return ProfileState(
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
      error: identical(error, _unset) ? this.error : error as String?,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier(this._firestoreServices) : super(const ProfileState()) {
    _loadProfile();
  }

  final FirebaseFirestoreServices _firestoreServices;

  Future<void> _loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final user = await _firestoreServices.getUser();
      state = state.copyWith(userProfile: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Persists an edited profile to Firestore, then updates local state.
  /// Uses merge semantics so partial edits never wipe unrelated fields.
  Future<void> updateProfile(UserModel updatedUser) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _firestoreServices.saveUser(updatedUser, onlyIfNew: false);
      state = state.copyWith(userProfile: updatedUser, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refreshProfile() async {
    await _loadProfile();
  }
}
