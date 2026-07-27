import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_assets.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/custom_elevated_button.dart';
import 'package:lms/core/presentation/widgets/custom_safe_area.dart';
import 'package:lms/core/routing/app_routing.dart';

class ResetPasswordSuccessScreen extends StatelessWidget {
  const ResetPasswordSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Success Image
            SizedBox(
              height: context.h(20),
              width: context.w(90),
              child: Image(image: AssetImage(AppIcons.passReset)),
            ),
            // Success Text
            Text(
              "Your Password has been updated successfully!",
              style: AppTextStyle.kSectionTitle.copyWith(color: AppColors.kPrimary),
            ).padOnly(top: context.h(3), bottom: context.h(3)),
            // Done Button
            CustomElevatedButton(
              elevation: 0,
              bWidth: double.infinity,
              borderRadius: context.w(3),
              height: context.h(6.75),
              title: "DONE",
              onPress: () => context.go(Routes.userType),
              buttonColor: AppColors.kPrimary,
            ),
          ],
        ).padOnly(right: context.w(5), left: context.w(5)),
      ),
    );
  }
}
