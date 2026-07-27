
import 'package:flutter/material.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_fonts.dart';



Future showCustomPopUp(
    BuildContext context,
    String title,
    String bodyText,
    String cancelText,
    Color cancelColor,
    String confirmText,
    Color confirmColor,
    Function()? onConfirm) async {
  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: AppColors.kWhite,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(16),
          ),
        ),
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(
              fontFamily: AppFonts.kBold,
              color: AppColors.kBlack,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 3),
        ),
        content: Text(
          bodyText,
          style: const TextStyle(fontSize: 16, color: AppColors.kBlack),
        ),
        actions: <Widget>[
          MaterialButton(
            child: Text(
              cancelText,
              style: TextStyle(fontSize: 15, color: cancelColor),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          MaterialButton(
            onPressed: onConfirm,
            child: Text(
              confirmText,
              style: TextStyle(fontSize: 15, color: confirmColor),
            ),
          ),
        ],
      );
    },
  );
}
