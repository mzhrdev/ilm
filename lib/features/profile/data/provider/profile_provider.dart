// lib/features/profile/data/provider/profile_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/auth/data/model/user_model.dart';

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  return ProfileNotifier();
});

class ProfileState {
  final UserModel? userProfile;
  final bool isLoading;
  final String? error;

  ProfileState({this.userProfile, this.isLoading = true, this.error});

  ProfileState copyWith({UserModel? userProfile, bool? isLoading, String? error}) {
    return ProfileState(
      userProfile: userProfile ?? this.userProfile,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier() : super(ProfileState()) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // TODO: Replace with actual API call or auth provider data
      await Future.delayed(const Duration(milliseconds: 500));

      state = state.copyWith(
        userProfile: UserModel(
          id: 'user_001',
          name: 'Name Here',
          email: 'namehere@example.com',
          profileImageUrl: null,
          skills: ['UI/UX', 'Graphics Design', 'Figma', 'Video Editor'],
          about:
              'Lorem ipsum dolor sit amet consectetur. Nec eget accumsan molestie prin. Integer rhoncus vitae nisi natoque ac mus tellus scelerisque.',
        ),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> updateProfile(UserModel updatedUser) async {
    state = state.copyWith(userProfile: updatedUser);
  }

  Future<void> refreshProfile() async {
    await _loadProfile();
  }
}
