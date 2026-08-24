import 'package:flutter/material.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/presentation/widgets/custom_text_button.dart';

class ScreenBottom extends StatelessWidget {
  final String question, bText;
  final VoidCallback onTap;
  const ScreenBottom({super.key, required this.question, required this.bText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Already Question
        Text(question),
        // Text Button for Navigation
        CustomTextButton(onPressed: onTap, text: bText, color: AppColors.kSecondary),
      ],
    );
  }
}
