// lib/features/settings/presentation/screens/settings_screen.dart

import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/auth/data/providers/auth_provider.dart';
import 'package:lms/features/settings/data/model/settings_menu_item_model.dart';
import 'package:lms/features/settings/presentation/widget/settings_menu_item_widget.dart';

import '../../data/provider/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsState = ref.watch(settingsProvider);
    final userProfile = settingsState.userProfile;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: settingsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(height: context.h(10)),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Settings Card
                      Container(
                        // ✅ Added top padding to create space between profile pic and tiles
                        padding: const EdgeInsets.only(top: 45, left: 16, right: 16, bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.blue[100]!),
                        ),
                        child: Column(
                          children: settingsState.menuItems.map((item) {
                            return SettingsMenuItemTile(
                              item: item,
                              onTap: () {
                                // ✅ Use a switch statement to handle each item individually
                                switch (item.type) {
                                  case SettingsMenuItemType.profile:
                                    context.push(Routes.editProfile);
                                    break;

                                  case SettingsMenuItemType.payment:
                                    context.push(Routes.payment); // Make sure to add this route
                                    break;

                                  case SettingsMenuItemType.terms:
                                    context.push(Routes.terms);
                                    break;

                                  case SettingsMenuItemType.help:
                                    context.push(Routes.helpCenter); // Make sure to add this route
                                    break;

                                  case SettingsMenuItemType.invite:
                                    //_shareInvite(context);
                                    break;

                                  case SettingsMenuItemType.logout:
                                    _showLogoutDialog(context, ref);
                                    break;
                                }
                              },
                            );
                          }).toList(),
                        ),
                      ),
                      // Profile Picture (positioned on top)
                      Positioned(
                        top: -70,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(100),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: _buildProfileImage(userProfile?.profileImageUrl),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 70), // Space for the overlapping profile picture
                ],
              ),
            ),
    );
  }

  // Helper to build the image or placeholder
  Widget _buildProfileImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return const Icon(Icons.person, size: 50, color: Colors.grey);
    }

    return ClipOval(
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.person, size: 50, color: Colors.grey);
        },
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: const Text(
          'Are you sure you want to log out of your account?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => context.pop(), // Closes the dialog
            child: const Text(
              'Cancel',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          // Log Out Button (Destructive)
          TextButton(
            onPressed: () {
              context.pop(); // Close dialog first

              // 1. Clear auth state / tokens here
              ref.read(authProvider.notifier).signOut();

              // 2. Navigate to Login screen and clear the stack
              context.go(Routes.signin);

              // Optional: Show a quick success message
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Logged out successfully')));
            },
            child: const Text(
              'Log Out',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
