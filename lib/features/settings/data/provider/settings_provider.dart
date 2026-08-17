import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/auth/data/model/user_model.dart';
import 'package:lms/features/settings/data/model/settings_menu_item_model.dart';

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsState {
  final UserModel? userProfile;
  final List<SettingsMenuItem> menuItems;
  final bool isLoading;

  SettingsState({this.userProfile, required this.menuItems, this.isLoading = false});

  SettingsState copyWith({UserModel? userProfile, List<SettingsMenuItem>? menuItems, bool? isLoading}) {
    return SettingsState(
      userProfile: userProfile ?? this.userProfile,
      menuItems: menuItems ?? this.menuItems,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState(menuItems: SettingsMenuItem.menuItems, isLoading: true)) {
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    state = state.copyWith(isLoading: true);

    // TODO: Replace this mock data with your actual Auth Provider data!
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(
      userProfile: UserModel(
        id: 'user_001',
        name: 'Fawais',
        email: 'fawais@university.edu',
        profileImageUrl: null,
        skills: ['Flutter', 'UI/UX'],
        about: 'Computer Science Student',
      ),
      isLoading: false,
    );
  }

  Future<void> updateProfile(UserModel profile) async {
    state = state.copyWith(userProfile: profile);
  }
}
