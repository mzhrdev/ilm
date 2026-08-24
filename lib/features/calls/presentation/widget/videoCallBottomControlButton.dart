import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:lms/core/constants/app_colors.dart';

Widget videoCallBottomControlButton({
  required IconData icon,
  required bool isActive,
  required VoidCallback onTap,
  required BuildContext context,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: isActive ? AppColors.kWhite : AppColors.kWhite.withAlpha(100),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: isActive ? AppColors.kBlack : AppColors.kWhite, size: context.h(3)),
    ),
  );
}
