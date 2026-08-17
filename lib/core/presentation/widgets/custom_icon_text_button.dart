import 'package:flutter/material.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_fonts.dart';

class CustomIconTextButton extends StatelessWidget {
  const CustomIconTextButton({
    super.key,
    required this.text,
    this.fontSize = 14,
    required this.onPressed,
    this.color = AppColors.kPrimary,
    required this.icon,
    this.iconColor = AppColors.kPrimary,
    this.iconSize = 24,
  });

  final String text;
  final double? fontSize;
  final void Function()? onPressed;
  final Color? color;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      icon: Icon(icon, color: iconColor, size: iconSize),
      style: TextButton.styleFrom(
        surfaceTintColor: AppColors.kTransparent,
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        foregroundColor: AppColors.kPrimary,
      ),
      onPressed: onPressed,
      label: Text(
        text,
        style: TextStyle(fontSize: fontSize, color: color, fontFamily: AppFonts.kMedium),
      ),
    );
  }
}
