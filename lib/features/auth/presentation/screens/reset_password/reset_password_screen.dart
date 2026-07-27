import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/custom_elevated_button.dart';
import 'package:lms/core/presentation/widgets/custom_icon_button.dart';
import 'package:lms/core/presentation/widgets/custom_password_text_field.dart';
import 'package:lms/core/presentation/widgets/custom_safe_area.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/auth/data/providers/auth_provider.dart';

class ResetPasswordScreen extends ConsumerWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authProvider);
    return CustomSafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            children: [
              // <-
              CustomIconButton(
                onTap: () => context.replace(Routes.resetPassEmail),
                icon: Icons.arrow_back,
                iconColor: AppColors.kPrimary,
              ).topLeftAlign.padAll(context.w(2)),
              // Reset Password Text
              Text(
                "Reset Password",
                style: AppTextStyle.kHeading.copyWith(fontSize: context.h(4)),
              ).padOnly(top: context.h(13)),
              // Elaborative Text
              Text(
                "At least 9 characters with uppercase and lowercase letters",
                style: AppTextStyle.kBodyMedium.copyWith(color: AppColors.kPrimary),
              ).padOnly(top: context.h(0.5), bottom: context.h(3)),

              // password heading
              Text(
                "New Password",
                style: AppTextStyle.kBodyMedium.copyWith(color: AppColors.kPrimary),
              ).leftAlign.padOnly(top: context.h(3), bottom: context.h(1)),
              // New Password Field
              CustomPasswordTextField(
                cursorColor: AppColors.kPrimary,
                focusedBorderColor: AppColors.kPrimary,
                controller: state.resetPassController,
                hintText: "xX1@...",
                labelText: null,
                borderWidth: context.w(0.5),
                enabledBorderColor: AppColors.kPrimary.withAlpha(100),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                validator: FieldValidator.password(),
              ),
              // confirm password heading
              Text(
                "Confirm Password",
                style: AppTextStyle.kBodyMedium.copyWith(color: AppColors.kPrimary),
              ).leftAlign.padOnly(top: context.h(3), bottom: context.h(1)),
              // Confirm Password Field
              CustomPasswordTextField(
                cursorColor: AppColors.kPrimary,
                borderWidth: context.w(0.5),
                controller: state.confirmPassController,
                hintText: null,
                labelText: null,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                validator: FieldValidator.equalTo(state.resetPassController),
                focusedBorderColor: AppColors.kPrimary.withAlpha(100),
                enabledBorderColor: AppColors.kPrimary.withAlpha(100),
              ).padBottom(context.h(6)),
              // Done Button
              CustomElevatedButton(
                elevation: 0,
                bWidth: double.infinity,
                borderRadius: context.w(3),
                height: context.h(6.75),
                title: "DONE",
                onPress: () => context.replace(Routes.resetPassSuccess),
                buttonColor: AppColors.kPrimary,
              ),
            ],
          ).padOnly(left: context.w(4), right: context.w(4)),
        ),
      ),
    );
  }
}
