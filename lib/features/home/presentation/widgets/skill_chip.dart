// lib/features/course_detail/widgets/skill_chip.dart

import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:Edvance/core/constants/app_colors.dart';
import 'package:Edvance/core/constants/app_text_styles.dart';

class SkillChip extends StatelessWidget {
  final String label;

  const SkillChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(4), vertical: context.h(1)),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.kWhite),
        borderRadius: BorderRadius.circular(context.w(6)),
      ),
      child: Text(label, style: AppTextStyle.kBodyMedium),
    );
  }
}
