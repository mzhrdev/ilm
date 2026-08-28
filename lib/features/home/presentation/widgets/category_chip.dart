// lib/features/home/presentation/widgets/category_chip.dart

import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({super.key, required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.w(2), vertical: context.h(.75)),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.kBlue.withAlpha(150) : AppColors.kGrey,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? AppColors.kBlue : AppColors.kBlack.withAlpha(150)),
        ),
        child: Text(
          label,
          style: AppTextStyle.kBodyMedium.copyWith(
            color: isSelected ? AppColors.kWhite : AppColors.kBlack,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: context.h(1.75),
          ),
        ),
      ),
    );
  }
}
