
import 'package:flutter/material.dart';
import 'package:Edvance/core/constants/app_colors.dart';
import 'package:Edvance/core/constants/app_fonts.dart';



class CustomIconElevatedButton extends StatelessWidget {
  const CustomIconElevatedButton({
    super.key,
    this.height = 50,
    this.width,
    this.fontSize = 16,
    this.buttonColor = AppColors.kPrimary,
    this.textColor = AppColors.kWhite,
    required this.title,
    this.loading = false,
    required this.onPress,
    this.borderSide = BorderSide.none,
    this.fontFamily = AppFonts.kMedium,
    this.borderRadius = 30,
    this.loadingIndicatorColor = AppColors.kWhite,
    required this.icon,
    this.iconColor = AppColors.kWhite,
    this.iconSize = 24,
    this.iconAlignment = IconAlignment.start,
  });
  final bool? loading;
  final String? title;
  final double? height, width, borderRadius;
  final Color? textColor, buttonColor, iconColor, loadingIndicatorColor;
  final void Function()? onPress;
  final IconData? icon;
  final double? fontSize;
  final double? iconSize;
  final String? fontFamily;
  final BorderSide borderSide;
  final IconAlignment iconAlignment;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          surfaceTintColor: AppColors.kTransparent,
          minimumSize: Size.zero,
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              borderRadius!,
            ),
          ),
          side: borderSide,
        ),
        onPressed: onPress,
        iconAlignment: iconAlignment,
        icon: Icon(
          icon,
          color: iconColor,
          size: iconSize,
        ),
        label: loading!
            ? CircularProgressIndicator(
                color: loadingIndicatorColor,
                strokeCap: StrokeCap.round,
              )
            : Text(
                title!,
                style: TextStyle(
                  color: textColor,
                  fontSize: fontSize,
                  fontFamily: fontFamily,
                ),
              ),
      ),
    );
  }
}
