import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:Edvance/core/constants/app_colors.dart';

class CustomImageButton extends StatelessWidget {
  const CustomImageButton({
    super.key,
    required this.onTap,
    required this.imagePath,
    this.iconColor = AppColors.kWhite,
    this.iconSize = 24,
    this.usedInAppBar = false,
    this.paddingAroundIcon = 10,
    this.highlightColor,
    this.splashColor,
    this.boxFit,
  });
  final void Function()? onTap;
  final BoxFit? boxFit;
  final String imagePath;
  final Color? iconColor;
  final double? iconSize;
  final bool? usedInAppBar;
  final double paddingAroundIcon;
  final Color? highlightColor;
  final Color? splashColor;
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Image.asset(
          imagePath,
          width: iconSize,
          height: iconSize,
          fit: boxFit ?? BoxFit.contain,
        ).padAll(usedInAppBar! ? 15 : paddingAroundIcon),
        Positioned.fill(
          child: Material(
            color: AppColors.kTransparent,
            child: InkWell(
              onTap: onTap,
              highlightColor: highlightColor,
              splashColor: splashColor,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
        ),
      ],
    );
  }
}
