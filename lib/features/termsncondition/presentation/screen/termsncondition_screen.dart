// lib/features/settings/presentation/screens/terms_and_conditions_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/routing/app_routing.dart';

class TermsAndConditionsScreen extends ConsumerWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          'Terms & Conditions',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('1. Acceptance of Terms'),
            _buildParagraph(
              'By accessing and using the LMS platform, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('2. User Accounts'),
            _buildParagraph(
              'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account. You must notify us immediately upon becoming aware of any breach of security or unauthorized use of your account.',
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('3. Course Enrollment & Payments'),
            _buildParagraph(
              'All course fees are non-refundable unless otherwise stated. By enrolling in a course, you agree to pay the specified fees. We reserve the right to modify course content, schedules, and instructors at any time without prior notice.',
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('4. Intellectual Property'),
            _buildParagraph(
              'All content provided on this platform, including but not limited to videos, text, graphics, and course materials, is the property of the LMS or its content suppliers and is protected by international copyright laws.',
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('5. Prohibited Activities'),
            _buildParagraph(
              'You agree not to use the platform for any unlawful purpose or any purpose prohibited under this clause. You agree not to use the platform in any way that could damage, disable, overburden, or impair the servers or networks.',
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('6. Termination'),
            _buildParagraph(
              'We may terminate or suspend access to our Service immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.',
            ),
            const SizedBox(height: 40), // Extra space at the bottom
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  // Helper for Section Titles
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
    );
  }

  // Helper for Paragraph Text
  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[700],
          height: 1.6, // Better line height for readability
        ),
      ),
    );
  }

  // Standard Bottom Navigation
  Widget _buildBottomNavigationBar(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 3, // Profile is active (since it's accessed from Settings)
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
            context.go(Routes.course);
            break;
          case 2:
            context.go(Routes.chat);
            break;
          case 3:
            context.go(Routes.profile);
            break;
        }
      },
    );
  }
}
