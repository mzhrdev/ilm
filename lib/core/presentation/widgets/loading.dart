import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_fonts.dart';

class Loading extends StatelessWidget {
  const Loading({super.key, this.color = AppColors.kPrimary, this.size = 40, this.text, this.textColor});
  final double size;
  final Color? color;
  final String? text;
  final Color? textColor;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SpinKitCircle(color: color, size: size),
        text != null
            ? Text(text!, style: TextStyle(color: textColor ?? AppColors.kBlack))
            : const SizedBox.shrink(),
      ],
    );
  }
}

// Changed: PReviously it was implemented using Getx, but now it
// implemented using Flutter built-in showDialog()

Future<void> loadingDialog(BuildContext context, {String? text}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.kBlack.withAlpha(100),
    builder: (_) => PopScope(
      canPop: false,

      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.all(40),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: AppColors.kSecondary, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (text != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 15),
                  child: Material(
                    color: AppColors.kTransparent,
                    child: Text(
                      text,
                      style: TextStyle(
                        color: AppColors.kWhite.withAlpha(100),
                        fontSize: MediaQuery.of(context).size.height / 55,
                        fontFamily: AppFonts.kMedium,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              const SizedBox(width: 150, child: SpinKitCircle(color: AppColors.kPrimary, size: 40)),
            ],
          ),
        ),
      ),
    ),
  );
}
