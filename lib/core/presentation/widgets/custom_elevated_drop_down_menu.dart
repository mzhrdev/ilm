import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:Edvance/core/constants/app_colors.dart';
import 'package:Edvance/core/constants/app_fonts.dart';

class CustomElevatedDropDownMenuButton extends StatelessWidget {
  const CustomElevatedDropDownMenuButton({
    super.key,
    // Removed required Keyword
    this.hintText,
    required this.dropdownMenuEntries,
    required this.onSelected,
    this.width,
    this.elevation,
    this.height,
    this.textController,
    this.borderRadius = 12,
    this.enabledBorderColor = AppColors.kWhite,
    this.textFontSize = 14,
    this.textFontFamily = AppFonts.kLight,
    this.textFontColor = AppColors.kPrimary,
  });

  // CHANGED: Made label nullable
  final String? hintText;
  final List<DropdownMenuEntry<dynamic>> dropdownMenuEntries;
  final void Function(dynamic)? onSelected;
  final TextEditingController? textController;
  final double? width;
  final double? elevation;
  // // CHANGED: Added height
  final double? height;

  final double borderRadius;
  final Color enabledBorderColor;
  final double? textFontSize;
  final String? textFontFamily;
  final Color? textFontColor;
  @override
  Widget build(BuildContext context) {
    return Material(
      // Uses your passed elevation value, or defaults to 4.0 if null
      elevation: elevation ?? 4.0,
      borderRadius: BorderRadius.circular(borderRadius),
      color: AppColors.kWhite,
      child: SizedBox(
        height: height ?? context.h(6.70),
        width: width ?? double.infinity,
        child: DropdownMenu<dynamic>(
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.all(AppColors.kWhite),
            surfaceTintColor: WidgetStateProperty.all(AppColors.kTransparent),
          ),
          controller: textController,
          hintText: hintText,
          //  Label removed
          textStyle: TextStyle(fontFamily: textFontFamily, fontSize: textFontSize, color: textFontColor),
          dropdownMenuEntries: dropdownMenuEntries,
          onSelected: onSelected,
          trailingIcon: const Icon(Icons.keyboard_arrow_down, size: 30),
          selectedTrailingIcon: const Icon(Icons.keyboard_arrow_up, size: 30),
          inputDecorationTheme: InputDecorationTheme(
            constraints: BoxConstraints.tight(
              // CHANGED: width = 40 to width = 70
              Size(width ?? context.w(70), context.h(8)),
            ), // CHANGED: Added height and height = 50 --> height = context.h(8)
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
        ),
      ),
    );
  }
}
