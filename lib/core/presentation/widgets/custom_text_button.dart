import 'package:flutter/material.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_fonts.dart';

class CustomTextButton extends StatelessWidget {
  const CustomTextButton({
    super.key,
    required this.text,
    // FontWeight Added
    this.fontWeight = FontWeight.bold,
    this.fontSize = 14,
    required this.onPressed,
    // Color changed from -> AppColors.kPrimary
    this.color = AppColors.kBlack,
    this.fontFamily = AppFonts.kRegular,
    this.bgColor = AppColors.kTransparent,
  });
  final Color? bgColor;
  final FontWeight? fontWeight;
  final String text;
  final double? fontSize;
  final void Function()? onPressed;
  final Color? color;
  final String? fontFamily;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        surfaceTintColor: AppColors.kTransparent,
        backgroundColor: bgColor,
        minimumSize: const Size(0, 0),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color, fontFamily: fontFamily),
      ),
    );
  }
}
