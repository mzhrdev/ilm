import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:Edvance/core/constants/app_colors.dart';
import 'package:Edvance/core/constants/app_fonts.dart';
import 'package:Edvance/core/constants/app_text_styles.dart';

class ShowSnackbar1 {
  static message(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        padding: 15.padAll(),
        backgroundColor: AppColors.kPrimary,
        content: Text(
          msg,
          style: AppTextStyle.kBodyMedium.copyWith(color: AppColors.kBlack, fontFamily: AppFonts.kMedium),
        ),
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.up,
        duration: const Duration(seconds: 4),
        margin: 15.padAll(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  static success(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        padding: 15.padAll(),
        backgroundColor: AppColors.kGreen, // kPrimary -> kGreen
        content: Text(
          msg,
          style: AppTextStyle.kBodyMedium.copyWith(
            color: AppColors.kWhite, //kBlack -> kWhite
            fontFamily: AppFonts.kMedium,
          ),
        ),
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.up,
        duration: const Duration(seconds: 4),
        margin: 15.padAll(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }

  static error(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        padding: 15.padAll(),
        backgroundColor: AppColors.kRed,
        content: Text(
          msg,
          style: AppTextStyle.kBodyMedium.copyWith(color: AppColors.kWhite, fontFamily: AppFonts.kMedium),
        ),
        behavior: SnackBarBehavior.floating,
        dismissDirection: DismissDirection.up,
        duration: const Duration(seconds: 4),
        margin: 15.padAll(),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      ),
    );
  }
}
