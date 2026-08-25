// lib/features/course_detail/widgets/course_info_card.dart

import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';

class CourseInfoCard extends StatelessWidget {
  final int lectures;
  final String duration;
  final bool hasCertificate;
  final int discount;

  const CourseInfoCard({
    super.key,
    required this.lectures,
    required this.duration,
    required this.hasCertificate,
    required this.discount,
  });

  @override
  Widget build(BuildContext context) {
    // Main Container - Blue Background
    return Container(
      padding: EdgeInsets.all(context.w(3)),
      decoration: BoxDecoration(
        color: AppColors.kBlue.withAlpha(70),
        borderRadius: BorderRadius.circular(context.w(6)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Lectures - 1+ Lectures
              _InfoItem(icon: Icons.play_circle_outline, label: '$lectures+ Lectures'),
              // Duration - e.g; 0 Weeks
              _InfoItem(icon: Icons.schedule, label: duration),
            ],
          ),
          SizedBox(height: context.h(3)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Certificate Icon
              if (hasCertificate) _InfoItem(icon: Icons.verified_user, label: 'Certificate'),
              // Offer - e.g; 10% off
              _InfoItem(icon: Icons.local_offer, label: '$discount% Off'),
            ],
          ),
        ],
      ),
    );
  }
}

// Info Item
class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoItem({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon
        Icon(icon, color: AppColors.kBlue),
        SizedBox(height: context.h(1)),
        // Label
        Text(label, style: AppTextStyle.kBodySmall),
      ],
    );
  }
}
