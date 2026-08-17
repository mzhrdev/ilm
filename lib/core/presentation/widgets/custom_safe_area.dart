import 'package:flutter/material.dart';
import 'package:lms/core/constants/app_colors.dart';

class CustomSafeArea extends StatelessWidget {
  const CustomSafeArea({
    super.key,
    required this.child,
    // Changed the color here from -> AppColors.kPrimary
    this.color = AppColors.kWhite,
  });
  final Widget child;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
      child: SafeArea(bottom: false, child: child),
    );
  }
}
