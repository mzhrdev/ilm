// lib/features/settings/presentation/screens/settings_screen.dart

import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/custom_icon_button.dart';
import 'package:lms/core/presentation/widgets/custom_safe_area.dart';
import 'package:lms/core/presentation/widgets/snackbar.dart';
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

    return CustomSafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.kWhite,
          elevation: 0,
          leading: CustomIconButton(
            onTap: () => context.pop(),
            icon: Icons.arrow_back_ios_new,
            paddingAroundIcon: context.w(4.5),
            iconColor: AppColors.kBlack,
          ),
          title: const Text('Settings', style: AppTextStyle.kHeading),
        ),
        body: settingsState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(context.w(4)),
                child: Column(
                  children: [
                    SizedBox(height: context.h(10)),
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Settings Card
                        Container(
                          padding: EdgeInsets.only(
                            top: context.h(6),
                            left: context.w(3),
                            right: context.w(3),
                            bottom: context.h(2),
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.kBlue.withAlpha(50),
                            borderRadius: BorderRadius.circular(context.w(4)),
                            border: Border.all(color: AppColors.kBlue),
                          ),
                          child: Column(
                            children: settingsState.menuItems.map((item) {
                              return SettingsMenuItemTile(
                                item: item,
                                onTap: () {
                                  switch (item.type) {
                                    case SettingsMenuItemType.profile:
                                      context.push(Routes.editProfile);
                                      break;
                                    case SettingsMenuItemType.payment:
                                      context.push(Routes.payment);
                                      break;
                                    case SettingsMenuItemType.terms:
                                      context.push(Routes.terms);
                                      break;
                                    case SettingsMenuItemType.help:
                                      context.push(Routes.helpCenter);
                                      break;
                                    case SettingsMenuItemType.invite:
                                      ShowSnackbar1.error(context, 'Invite Functionality Coming Soon!');
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
                              width: context.w(30),
                              height: context.h(12),
                              decoration: BoxDecoration(
                                color: AppColors.kGrey,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.kWhite, width: context.h(0.5)),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.kBlack.withAlpha(100),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: _buildProfileImage(userProfile?.profileImageUrl, context),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: context.h(4)),
                  ],
                ),
              ),
      ),
    );
  }

  // Helper to build the image or placeholder
  Widget _buildProfileImage(String? imageUrl, BuildContext context) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Icon(Icons.person, size: context.h(6), color: AppColors.kBlack.withAlpha(150));
    }

    return ClipOval(
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.person, size: context.h(6), color: AppColors.kBlack.withAlpha(150));
        },
      ),
    );
  }

  // Show Logout Dialog Method Definition
  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Log Out', style: AppTextStyle.kBodyLarge),
        content: Text(
          'Are you sure you want to log out of your account?',
          style: AppTextStyle.kBodyMedium.copyWith(color: AppColors.kBlack.withAlpha(100)),
        ),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => context.pop(),
            child: Text('Cancel', style: AppTextStyle.kBodyLarge.copyWith(color: AppColors.kBlack)),
          ),
          // Log Out Button (Destructive)
          TextButton(
            onPressed: () {
              context.pop();
              // 1. Clear auth state / tokens here
              ref.read(authProvider.notifier).signOut();
              // 2. Navigate to Login screen and clear the stack
              context.go(Routes.signin);
              // Optional: Show a quick success message
              ShowSnackbar1.success(context, 'Logged out successfully');
            },
            child: Text(
              'Log Out',
              style: AppTextStyle.kBodyLarge.copyWith(
                color: AppColors.kCallEndB,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
