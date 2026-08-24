import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:lms/core/constants/app_colors.dart';

Widget buildFloatingButton({
  required IconData icon,
  required VoidCallback onTap,
  required BuildContext cont,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: cont.w(15),
      height: cont.h(10),
      decoration: BoxDecoration(color: AppColors.kBlack.withAlpha(150), shape: BoxShape.circle),
      child: Icon(icon, color: AppColors.kWhite, size: cont.w(7)),
    ),
  );
}
