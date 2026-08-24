// Custom Control Button Widget
import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';

Widget audioCallControlButton({
  required IconData icon,
  required String label,
  required bool isActive,
  required VoidCallback onTap,
  required BuildContext context,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Column(
      children: [
        Container(
          width: context.w(19),
          height: context.h(8),
          decoration: BoxDecoration(
            color: isActive ? AppColors.kWhite : AppColors.kWhite.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: isActive ? AppColors.kBlack : AppColors.kWhite, size: context.h(4)),
        ),
        SizedBox(height: context.h(1)),
        Text(label, style: AppTextStyle.kBodyMedium.copyWith(color: AppColors.kWhite)),
      ],
    ),
  );
}
