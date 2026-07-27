import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_fonts.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/custom_elevated_button.dart';
import 'package:lms/core/presentation/widgets/custom_icon_button.dart';
import 'package:lms/core/presentation/widgets/custom_safe_area.dart';
import 'package:lms/core/presentation/widgets/custom_text_field.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/auth/data/providers/auth_provider.dart';

class ResetPasswordEmailScreen extends ConsumerWidget {
  const ResetPasswordEmailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authProvider);
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.kWhite,
        body: SingleChildScrollView(
          child: Column(
            children: [
              // <-
              CustomIconButton(
                onTap: () => context.pop(),
                icon: Icons.arrow_back,
                iconColor: AppColors.kPrimary,
              ).topLeftAlign.padAll(context.w(2)),
              // Reset Password Text
              Text(
                "Reset Password",
                style: AppTextStyle.kHeading.copyWith(fontSize: context.h(4)),
              ).padOnly(top: context.h(15)),
              // Text
              Text(
                "Enter email for a reset link",
                style: AppTextStyle.kSectionTitle.copyWith(color: AppColors.kPrimary),
              ).padOnly(left: context.w(6), right: context.w(6), bottom: context.h(5)),
              // Email Text Field
              CustomTextField(
                cursorColor: AppColors.kPrimary,
                borderWidth: context.w(0.5),
                controller: state.resetPassEmailController,
                hintText: "...@gmail.com",
                focusedBorderColor: AppColors.kPrimary,
                enabledBorderColor: AppColors.kPrimary.withAlpha(100),
                labelText: "Email",
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.done,
                validator: FieldValidator.email(),
              ).padOnly(bottom: context.h(5), top: context.h(1), left: context.w(6), right: context.w(6)),
              // Send Button
              CustomElevatedButton(
                buttonColor: AppColors.kPrimary,
                elevation: 0,

                bWidth: context.w(95),
                borderRadius: context.w(3),
                fontSize: context.h(2.75),
                fontFamily: AppFonts.kLight,
                height: context.h(6.5),
                title: "Send",
                onPress: () {
                  context.replace(Routes.resetPass);
                },
              ).padOnly(left: context.w(6), right: context.w(6)),
            ],
          ),
        ),
      ),
    );
  }
}
