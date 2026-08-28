// lib/features/settings/presentation/screens/help_center_screen.dart
import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_fonts.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/custom_elevated_button.dart';
import 'package:lms/core/presentation/widgets/custom_icon_button.dart';
import 'package:lms/core/presentation/widgets/custom_safe_area.dart';
import 'package:lms/core/presentation/widgets/custom_text_field.dart';
import 'package:lms/core/presentation/widgets/snackbar.dart';
import 'package:lms/features/helpCenter/data/dummy_data/faq_list.dart';
import 'package:lms/features/helpCenter/data/dummy_data/help_categories.dart';

class HelpCenterScreen extends ConsumerStatefulWidget {
  const HelpCenterScreen({super.key});
  @override
  ConsumerState<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends ConsumerState<HelpCenterScreen> {
  final _searchController = TextEditingController();
  int? _expandedQuestionIndex;
  // Dispose Method
  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Build Method
  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.kWhite,
          elevation: 0,
          leading: CustomIconButton(
            onTap: () => context.pop(),
            icon: Icons.arrow_back_ios_new,
            iconColor: AppColors.kBlack,
            paddingAroundIcon: context.w(4),
          ),
          title: const Text('Help Center', style: AppTextStyle.kHeading),
        ),
        body: Column(
          children: [
            // Search Bar
            CustomTextField(
              controller: _searchController,
              hintText: 'How can we help you?',
              hintTextColor: AppColors.kBlack.withAlpha(150),
              isPrefixIconEnabled: true,
              preFixIcon: Icons.search,
              labelText: null,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              validator: FieldValidator.required(),
              fillColor: AppColors.kGrey.withAlpha(50),
              filled: true,
              enabledBorderColor: AppColors.kGrey,
              contentPadding: EdgeInsets.symmetric(horizontal: context.w(3), vertical: context.h(2)),
              onChanged: (val) {
                //TODO: Apply Search Filter functionality
              },
            ).padAll(context.w(4.5)),

            // Contact Support Button
            CustomElevatedButton(
              borderRadius: context.w(4),
              bWidth: context.w(93),
              elevation: 0,
              fontFamily: AppFonts.kBold,
              title: 'Contact Support',
              onPress: () {
                _showContactSupportDialog();
              },
            ),
            SizedBox(height: context.h(2.5)),

            // Help Categories
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: context.w(4)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Browse Categories', style: AppTextStyle.kSectionTitle),
                    SizedBox(height: context.h(1.5)),
                    // Categories Grid
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: helpCategories.length,
                      itemBuilder: (context, index) {
                        final category = helpCategories[index];
                        // category Card Builder Method
                        return _buildCategoryCard(category);
                      },
                    ),

                    SizedBox(height: context.h(4.25)),

                    // FAQ Section
                    const Text('Frequently Asked Questions', style: AppTextStyle.kSectionTitle),
                    SizedBox(height: context.h(1)),

                    ...faqList.asMap().entries.map((entry) {
                      final index = entry.key;
                      final faq = entry.value;
                      // FAQ Item Builder Method
                      return _buildFAQItem(faq['question']!, faq['answer']!, index);
                    }),

                    SizedBox(height: context.h(6)), // Space for bottom nav
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Category Card Builder Method Definition
  Widget _buildCategoryCard(Map<String, dynamic> category) {
    return GestureDetector(
      onTap: () {
        // Navigate to category-specific help
        ShowSnackbar1.error(context, '${category['title']} coming soon!');
      },
      child: Container(
        padding: EdgeInsets.all(context.w(4)),
        decoration: BoxDecoration(
          color: AppColors.kGrey.withAlpha(80),
          borderRadius: BorderRadius.circular(context.w(4)),
          border: Border.all(color: AppColors.kBlack.withAlpha(50)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(category['icon'] as IconData, color: category['color'] as Color, size: context.h(4)),
            SizedBox(height: context.h(1.25)),
            Text(category['title'] as String, style: AppTextStyle.kBodyMedium),
          ],
        ),
      ),
    );
  }

  // FAQ item Builder Method Definition
  Widget _buildFAQItem(String question, String answer, int index) {
    final isExpanded = _expandedQuestionIndex == index;

    return Container(
      margin: EdgeInsets.only(bottom: context.h(1.5)),
      child: Material(
        color: AppColors.kGrey.withAlpha(80),
        borderRadius: BorderRadius.circular(context.w(4)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.kBlack.withAlpha(80)),
          ),
          child: Column(
            children: [
              ListTile(
                title: Text(question, style: AppTextStyle.kBodyLarge),
                trailing: Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                  color: AppColors.kBlack.withAlpha(150),
                ),
                onTap: () {
                  setState(() {
                    _expandedQuestionIndex = isExpanded ? null : index;
                  });
                },
              ),
              if (isExpanded)
                Text(
                  answer,
                  style: AppTextStyle.kBodyMedium,
                ).padOnly(left: context.w(3.5), right: context.w(3.5), bottom: context.h(2)),
            ],
          ),
        ),
      ),
    );
  }

  // Bottom Sheet for Contact Support Builder Method Definition
  void _showContactSupportDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(context.w(5)))),
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: context.w(30),
              height: context.h(0.5),
              decoration: BoxDecoration(
                color: AppColors.kBlack.withAlpha(150),
                borderRadius: BorderRadius.circular(context.w(3)),
              ),
            ),
          ),
          SizedBox(height: context.h(3.5)),
          const Text('Contact Support', style: AppTextStyle.kSectionTitle),
          SizedBox(height: context.h(1.5)),
          Text(
            'Choose your preferred method to reach us',
            style: AppTextStyle.kBodySmall.copyWith(color: AppColors.kBlack.withAlpha(150)),
          ),
          SizedBox(height: context.h(2)),
          // EMAIL US
          _buildContactOption(
            icon: Icons.email_outlined,
            title: 'Email Us',
            subtitle: 'support@lmsapp.com',
            onTap: () {
              // TODO: Launch email app
              context.pop();
              ShowSnackbar1.success(context, 'Opening email app...');
            },
          ),
          // CALL US
          _buildContactOption(
            icon: Icons.phone_outlined,
            title: 'Call Us',
            subtitle: '+92 300 1234567',
            onTap: () {
              // TODO: Launch phone dialer
              context.pop();
              ShowSnackbar1.success(context, 'Opening phone dialer....');
            },
          ),
          // LIVE CHAT
          _buildContactOption(
            icon: Icons.chat_bubble_outline,
            title: 'Live Chat',
            subtitle: 'Chat with our support team',
            onTap: () {
              context.pop();
              // TODO: Navigate to live chat screen
              ShowSnackbar1.success(context, 'Live Chat coming soon!.');
            },
          ),
          SizedBox(height: context.h(4)),
        ],
      ).padAll(context.w(5)),
    );
  }

  // Contact Option Card Builder Method Definition
  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: context.h(2)),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.kGrey.withAlpha(80),
          borderRadius: BorderRadius.circular(context.w(4)),
          border: Border.all(color: AppColors.kBlack.withAlpha(100)),
        ),
        child: Row(
          children: [
            // Icon Container
            Container(
              width: context.w(10),
              height: context.h(5),
              decoration: BoxDecoration(color: AppColors.kWhite, shape: BoxShape.circle),
              child: Icon(icon, color: AppColors.kBlack),
            ),
            SizedBox(width: context.w(3)),
            // Text (Email/Call/Chat + Detail(e.g: number == 15428471436))
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyle.kBodyLarge),
                  SizedBox(height: context.h(0.5)),
                  Text(subtitle, style: AppTextStyle.kBodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.kBlack.withAlpha(150)),
          ],
        ),
      ),
    );
  }
}
