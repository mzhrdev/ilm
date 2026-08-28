import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/custom_icon_button.dart';
import 'package:lms/core/presentation/widgets/custom_safe_area.dart';

class TermsAndConditionsScreen extends ConsumerWidget {
  const TermsAndConditionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomSafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.kWhite,
          elevation: 0,
          leading: CustomIconButton(
            onTap: () => context.pop(),
            icon: Icons.arrow_back_ios_new,
            paddingAroundIcon: context.w(4),
            iconColor: AppColors.kBlack,
          ),

          title: const Text('Terms & Conditions', style: AppTextStyle.kHeading),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(context.w(5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('1. Acceptance of Terms'),
              _buildParagraph(
                'By accessing and using the lms platform, you accept and agree to be bound by the terms and provision of this agreement. If you do not agree to abide by the above, please do not use this service.',
              ),
              SizedBox(height: context.h(3)),

              _buildSectionTitle('2. User Accounts'),
              _buildParagraph(
                'You are responsible for maintaining the confidentiality of your account and password. You agree to accept responsibility for all activities that occur under your account. You must notify us immediately upon becoming aware of any breach of security or unauthorized use of your account.',
              ),
              SizedBox(height: context.h(3)),

              _buildSectionTitle('3. Course Enrollment & Payments'),
              _buildParagraph(
                'All course fees are non-refundable unless otherwise stated. By enrolling in a course, you agree to pay the specified fees. We reserve the right to modify course content, schedules, and instructors at any time without prior notice.',
              ),
              SizedBox(height: context.h(3)),

              _buildSectionTitle('4. Intellectual Property'),
              _buildParagraph(
                'All content provided on this platform, including but not limited to videos, text, graphics, and course materials, is the property of the lms or its content suppliers and is protected by international copyright laws.',
              ),
              SizedBox(height: context.h(3)),

              _buildSectionTitle('5. Prohibited Activities'),
              _buildParagraph(
                'You agree not to use the platform for any unlawful purpose or any purpose prohibited under this clause. You agree not to use the platform in any way that could damage, disable, overburden, or impair the servers or networks.',
              ),
              SizedBox(height: context.h(3)),

              _buildSectionTitle('6. Termination'),
              _buildParagraph(
                'We may terminate or suspend access to our Service immediately, without prior notice or liability, for any reason whatsoever, including without limitation if you breach the Terms.',
              ),
              SizedBox(height: context.h(5)),
            ],
          ),
        ),
      ),
    );
  }

  // Helper for Section Titles
  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyle.kSectionTitle);
  }

  // Helper for Paragraph Text
  Widget _buildParagraph(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(text, style: AppTextStyle.kBodyMedium.copyWith(color: AppColors.kBlack.withAlpha(100))),
    );
  }
}
