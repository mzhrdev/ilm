import 'package:flutter/material.dart';
import 'package:Edvance/core/constants/app_colors.dart';
import 'package:Edvance/core/constants/app_fonts.dart';

class CustomElevatedButton extends StatelessWidget {
  const CustomElevatedButton({
    super.key,
    this.height = 50,
    this.bWidth,
    this.tWidth,
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
    this.circularProgressStrokeWidth = 4,
    this.elevation = 5,
    this.iconAsset, // Added optional field
    this.iconSize = 20, // Optional control for icon bounding dimensions
  });

  final double? elevation;
  final bool? loading;
  final String? title;
  final double? height, bWidth, fontSize, borderRadius, tWidth;
  final Color? textColor, buttonColor, loadingIndicatorColor;
  final void Function()? onPress;
  final BorderSide borderSide;
  final String? fontFamily;
  final double circularProgressStrokeWidth;
  final String? iconAsset; // Added declaration
  final double iconSize; // Added declaration

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: bWidth,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          elevation: elevation,
          surfaceTintColor: AppColors.kTransparent,
          backgroundColor: buttonColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius!), side: borderSide),
        ),
        onPressed: onPress,
        child: loading!
            ? CircularProgressIndicator(
                color: loadingIndicatorColor,
                strokeCap: StrokeCap.round,
                strokeWidth: circularProgressStrokeWidth,
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (iconAsset != null) ...[
                    Image.asset(iconAsset!, width: iconSize, height: iconSize),
                    SizedBox(width: tWidth),
                  ],

                  Text(
                    title!,
                    style: TextStyle(color: textColor, fontSize: fontSize, fontFamily: fontFamily),
                  ),
                ],
              ),
      ),
    );
  }
}
