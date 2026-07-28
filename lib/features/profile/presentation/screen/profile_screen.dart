import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
      backgroundColor: Colors.white,
      body: profileState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : profileState.error != null
          ? _buildErrorState(ref)
          : userProfile == null
          ? const Center(child: Text('No profile data'))
          : _buildProfileContent(context, userProfile),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildErrorState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          const Text('Failed to load profile'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => ref.read(profileProvider.notifier).refreshProfile(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, userProfile) {
    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
            onPressed: () => context.go(Routes.home),
          ),
          title: const Text(
            'Profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          pinned: true,
        ),

        // Profile Content
        SliverToBoxAdapter(
          child: Padding(
            // ✅ FIX: Increased top padding from 16 to 32 to create a gap below the AppBar
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Profile Card
                    Container(
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
                            // ✅ NEW: Edit Button using IconButton (Top Right)
                            Align(
                              alignment: Alignment.topRight,
                              child: IconButton(
                                onPressed: () {
                                  context.push(Routes.editProfile);
                                },
                                icon: const Icon(Icons.edit, size: 18, color: Colors.black87),
                                style: IconButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: const CircleBorder(), // Makes it perfectly circular
                                  padding: const EdgeInsets.all(8),
                                  elevation: 2, // This adds the subtle shadow automatically!
                                ),
                              ),
                            ),
                            // Name
                            Center(
                              child: Text(
                                userProfile.name,
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                            ),

                            // Email/Title
                            Center(
                              child: Text(
                                userProfile.email,
                                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                textAlign: TextAlign.center,
                              ),
                            ),

                            const SizedBox(height: 24),

                            // About Me Section
                            const Text(
                              'About Me',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              userProfile.about ?? 'No about information',
                              style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5),
                            ),

                            const SizedBox(height: 24),

                            // My Skills Section
                            const Text(
                              'My Skills',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(height: 12),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              // ✅ FIX: Added <SkillChip> to explicitly tell Dart the return type
                              children: (userProfile.skills ?? [])
                                  .map<SkillChip>((skill) => SkillChip(label: skill))
                                  .toList(),
                            ),

                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ),

                    // Profile Picture (overlapping)
                    Positioned(
                      top: -50,
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
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: _buildProfileImage(userProfile.profileImageUrl),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

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

  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3, // Profile is active
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Home'),
        BottomNavigationBarItem(
          icon: Icon(Icons.school_outlined),
          activeIcon: Icon(Icons.school),
          label: 'Courses',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          activeIcon: Icon(Icons.chat_bubble),
          label: 'Messages',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          activeIcon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
      onTap: (index) {
        switch (index) {
          case 0:
            context.go(Routes.home);
            break;
          case 1:
            // TO DO:  Should convert it into courses
            context.go(Routes.courseDetail);
            break;
          case 2:
            context.go(Routes.chat);
            break;
          case 3:
            // Already on profile
            break;
        }
      },
    );
  }
}
