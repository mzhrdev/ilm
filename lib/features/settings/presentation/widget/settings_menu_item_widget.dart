import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/features/settings/data/model/settings_menu_item_model.dart';

class SettingsMenuItemTile extends StatelessWidget {
  final SettingsMenuItem item;
  final VoidCallback onTap;
  const SettingsMenuItemTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: context.w(3), vertical: context.h(2)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.w(4)),
          border: Border.all(color: AppColors.kWhite),
        ),
        child: Row(
          children: [
            // Icon
            Icon(
              item.icon,
              color: item.isDestructive ? AppColors.kCallEndB : AppColors.kBlack,
              size: context.h(3),
            ),
            SizedBox(width: context.w(4)),
            // Title
            Expanded(
              child: Text(
                item.title,
                style: AppTextStyle.kBodyLarge.copyWith(
                  color: item.isDestructive ? AppColors.kCallEndB : AppColors.kBlack,
                ),
              ),
            ),
            // Chevron >
            Icon(Icons.chevron_right, color: AppColors.kBlack.withAlpha(80), size: context.h(3.5)),
          ],
        ),
      ),
    ).padOnly(bottom: context.h(0.5));
  }
}
