import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/custom_icon_button.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/home/presentation/widgets/skill_chip.dart';

import '../../data/provider/profile_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileProvider);
    final userProfile = profileState.userProfile;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTextStyle.kBodyLarge.copyWith(
            fontSize: context.h(3),
            fontWeight: FontWeight.bold,
            color: AppColors.kBlack,
          ),
        ),
        leading: CustomIconButton(
          onTap: () => context.go(Routes.home),
          icon: Icons.arrow_back_ios_new,
          iconColor: AppColors.kBlack,
        ),
      ),
      backgroundColor: Colors.white,
      body: profileState.isLoading
          // Circular Progress Indicator
          ? const Center(child: CircularProgressIndicator())
          : profileState.error != null
          // Error State
          ? _buildErrorState(ref, context)
          : userProfile == null
          // Text when null user profile data
          ? const Center(child: Text('No profile data'))
          // Container profile
          : _buildProfileContent(context, userProfile),
    );
  }

  // Error State Build Method
  Widget _buildErrorState(WidgetRef ref, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.kRed, size: context.h(5)),
          SizedBox(height: context.h(3)),
          const Text('Failed to load profile'),
          SizedBox(height: context.h(5)),
          ElevatedButton(
            onPressed: () => ref.read(profileProvider.notifier).refreshProfile(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  // Profile Card
  Widget _buildProfileContent(BuildContext context, userProfile) {
    return Column(
      children: [
        // Content
        Expanded(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Profile Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Edit Button
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () {
                            context.push(Routes.editProfile);
                          },
                          icon: const Icon(Icons.edit, size: 18, color: Colors.black87),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.white,
                            shape: const CircleBorder(),
                            padding: const EdgeInsets.all(8),
                            elevation: 2,
                          ),
                        ),
                      ),

                      // Name
                      Center(child: Text(userProfile.name, style: AppTextStyle.kBodyLarge)),

                      // Email
                      Center(child: Text(userProfile.email, style: AppTextStyle.kBodyLarge)),

                      const SizedBox(height: 24),

                      // About
                      const Text('About Me', style: AppTextStyle.kBodyLarge),
                      const SizedBox(height: 8),
                      Text(userProfile.about ?? 'No about information', style: AppTextStyle.kBodyMedium),

                      const SizedBox(height: 24),

                      // Skills
                      const Text('My Skills', style: AppTextStyle.kBodyLarge),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: context.w(4),
                        runSpacing: context.w(4),
                        children: (userProfile.skills ?? [])
                            .map<SkillChip>((skill) => SkillChip(label: skill))
                            .toList(),
                      ),
                    ],
                  ).padOnly(),
                ),
              ),

              /// Profile Image
              Positioned(
                top: -context.h(4),
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.kGrey,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.kWhite, width: context.w(2)),
                    ),
                    child: _buildProfileImage(userProfile.profileImageUrl, context),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileImage(String? imageUrl, BuildContext context) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Icon(Icons.person, size: context.h(8), color: AppColors.kGrey);
    }

    return ClipOval(
      child: Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.person, size: context.h(8), color: AppColors.kGrey);
        },
      ),
    );
  }
}
