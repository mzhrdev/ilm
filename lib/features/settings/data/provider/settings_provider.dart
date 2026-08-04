// lib/features/settings/data/provider/settings_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
// Make sure this import path matches where your UserModel is located
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

  // ✅ THIS IS THE METHOD THAT WAS MISSING
  Future<void> handleMenuItemTap(SettingsMenuItemType type) async {
    switch (type) {
      case SettingsMenuItemType.profile:
        await _navigateToEditProfile();
        break;
      case SettingsMenuItemType.payment:
        await _navigateToPaymentOptions();
        break;
      case SettingsMenuItemType.terms:
        await _navigateToTermsAndConditions();
        break;
      case SettingsMenuItemType.help:
        await _navigateToHelpCenter();
        break;
      case SettingsMenuItemType.invite:
        await _shareInvite();
        break;
      case SettingsMenuItemType.logout:
        await _showLogoutConfirmation();
        break;
    }
  }

  Future<void> _navigateToEditProfile() async {
    print('Navigate to Edit Profile');
    // Add your GoRouter navigation here later
  }

  Future<void> _navigateToPaymentOptions() async {
    print('Navigate to Payment Options');
  }

  Future<void> _navigateToTermsAndConditions() async {
    print('Navigate to Terms & Conditions');
  }

  Future<void> _navigateToHelpCenter() async {
    print('Navigate to Help Center');
  }

  Future<void> _shareInvite() async {
    print('Share invite with friends');
  }

  Future<void> _showLogoutConfirmation() async {
    print('Show logout confirmation');
  }

  Future<void> updateProfile(UserModel profile) async {
    state = state.copyWith(userProfile: profile);
  }
}
