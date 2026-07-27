
import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:lms/core/constants/app_colors.dart';



class CustomIconButton extends StatelessWidget {
  const CustomIconButton({
    super.key,
    required this.onTap,
    required this.icon,
    this.iconColor = AppColors.kWhite, 
    this.iconSize = 24,
    this.usedInAppBar = false,
    this.paddingAroundIcon = 10,
    this.highlightColor,
    this.splashColor,
  });
  final void Function()? onTap;
  final IconData? icon;
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
        Icon(
          icon,
          color: iconColor,
          size: iconSize,
        ).padAll(
          usedInAppBar! ? 15 : paddingAroundIcon,
        ),
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

