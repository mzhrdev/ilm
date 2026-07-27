import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_fonts.dart';
import 'package:lms/core/constants/app_text_styles.dart';

class CustomDropDownMenuButton extends StatelessWidget {
  const CustomDropDownMenuButton({
    super.key,
    // Removed required Keyword
    this.label,
    required this.dropdownMenuEntries,
    required this.onSelected,
    this.width,
    // CHANGED: Added height
    this.height,
    this.textController,
    this.borderRadius = 12,
    this.enabledBorderColor = AppColors.kPrimary,
    this.textFontSize = 14,
    this.textFontFamily = AppFonts.kLight,
    this.textFontColor = AppColors.kPrimary,
  });

  // CHANGED: Made label nullable
  final String? label;
  final List<DropdownMenuEntry<dynamic>> dropdownMenuEntries;
  final void Function(dynamic)? onSelected;
  final TextEditingController? textController;
  final double? width;
  // CHANGED: Added height
  final double? height;

  final double borderRadius;
  final Color enabledBorderColor;
  final double? textFontSize;
  final String? textFontFamily;
  final Color? textFontColor;
  @override
  Widget build(BuildContext context) {
    return DropdownMenu<dynamic>(
      menuStyle: MenuStyle(
        backgroundColor: WidgetStateProperty.all(AppColors.kWhite),
        surfaceTintColor: WidgetStateProperty.all(AppColors.kTransparent),
      ),
      controller: textController,
      label:
          // CHANGED: Conditionally render Text widget if label is not null
          label != null
          ? Text(
              label!, // Use ! to assert non-null after the check
              style: AppTextStyle.kBodyMedium.copyWith(
                fontFamily: AppFonts.kMedium,
                color: AppColors.kPrimary,
              ),
            )
          // If label is null, pass null to DropdownMenu's label
          : null,
      textStyle: TextStyle(fontFamily: textFontFamily, fontSize: textFontSize, color: textFontColor),
      dropdownMenuEntries: dropdownMenuEntries,
      onSelected: onSelected,
      trailingIcon: const Icon(Icons.arrow_drop_down_rounded, size: 30),
      selectedTrailingIcon: const Icon(Icons.arrow_drop_up_rounded, size: 30),
      inputDecorationTheme: InputDecorationTheme(
        constraints: BoxConstraints.tight(Size(width ?? context.w(40), height ?? 50)),
        isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(12, 0, 12, 0),
        border: InputBorder.none,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(color: enabledBorderColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius)),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.kRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: AppColors.kRed, width: 1.5),
        ),
      ),
      expandedInsets: EdgeInsets.zero,
    );
  }
}
