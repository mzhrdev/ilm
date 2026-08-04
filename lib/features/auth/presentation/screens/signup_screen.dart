import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_assets.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_fonts.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/custom_elevated_button.dart';
import 'package:lms/core/presentation/widgets/custom_password_text_field.dart';
import 'package:lms/core/presentation/widgets/custom_safe_area.dart';
import 'package:lms/core/presentation/widgets/custom_text_field.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/auth/data/providers/auth_provider.dart';
import 'package:lms/features/auth/presentation/widgets/screen_bottom.dart';
import 'package:lms/features/auth/presentation/widgets/screen_divider.dart';

class SignupScreen extends ConsumerWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.kWhite,
        body: SingleChildScrollView(
          child: Form(
            key: auth.signUpFormKey,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    // Sign Up Text
                    Text(
                      "Sign Up",
                      style: AppTextStyle.kHeading.copyWith(
                        color: AppColors.kPrimary,
                        fontSize: context.h(4),
                      ),
                    ).padOnly(top: context.h(6)),
                  ],
                ),
                // Text for asking to fill up details
                Text(
                  "Create an account to begin your Learning Journey",
                  style: AppTextStyle.kBodyLarge.copyWith(color: AppColors.kPrimary),
                ).padOnly(top: context.h(2)),
                // User name heading
                Text(
                  "Full Name",
                  style: AppTextStyle.kBodyMedium.copyWith(color: AppColors.kPrimary),
                ).leftAlign.padOnly(top: context.h(5), bottom: context.h(1)),
                // User name text field
                CustomTextField(
                  cursorColor: AppColors.kPrimary,
                  borderWidth: context.w(0.5),
                  focusedBorderColor: AppColors.kPrimary.withAlpha(100),
                  enabledBorderColor: AppColors.kPrimary.withAlpha(100),
                  controller: auth.userNameController,
                  hintText: 'Enter Your Name',
                  labelText: null,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: FieldValidator.required(),
                ),
                // email heading
                Text(
                  "Email",
                  style: AppTextStyle.kBodyMedium.copyWith(color: AppColors.kPrimary),
                ).leftAlign.padOnly(top: context.h(3), bottom: context.h(1)),
                // email text field
                CustomTextField(
                  cursorColor: AppColors.kPrimary,
                  borderWidth: context.w(0.5),
                  focusedBorderColor: AppColors.kPrimary.withAlpha(100),
                  enabledBorderColor: AppColors.kPrimary.withAlpha(100),
                  controller: auth.authEmailController,
                  hintText: "...@gmail.com",
                  labelText: null,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: FieldValidator.email(),
                ),
                // password heading
                Text(
                  "Password",
                  style: AppTextStyle.kBodyMedium.copyWith(color: AppColors.kPrimary),
                ).leftAlign.padOnly(top: context.h(3), bottom: context.h(1)),
                // password text field
                CustomPasswordTextField(
                  cursorColor: AppColors.kPrimary,
                  borderWidth: context.w(0.5),
                  controller: auth.authPasswordController,
                  hintText: "xX1@....",
                  labelText: null,
                  focusedBorderColor: AppColors.kPrimary.withAlpha(100),
                  enabledBorderColor: AppColors.kPrimary.withAlpha(100),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.next,
                  validator: FieldValidator.password(),
                ),
                // confirm password heading
                Text(
                  "Confirm Password",
                  style: AppTextStyle.kBodyMedium.copyWith(color: AppColors.kPrimary),
                ).leftAlign.padOnly(top: context.h(3), bottom: context.h(1)),
                // confirm password text field
                CustomPasswordTextField(
                  cursorColor: AppColors.kPrimary,
                  borderWidth: context.w(0.5),
                  controller: auth.confirmPassController,
                  hintText: null,
                  labelText: null,
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  validator: FieldValidator.equalTo(auth.authPasswordController),
                  focusedBorderColor: AppColors.kPrimary.withAlpha(100),
                  enabledBorderColor: AppColors.kPrimary.withAlpha(100),
                ).padBottom(context.h(3)),
                // signup button
                CustomElevatedButton(
                  loading: auth.isLoading,
                  elevation: 0,
                  bWidth: double.infinity,
                  borderRadius: context.w(3),
                  height: context.h(6.5),
                  title: "SIGN UP",
                  onPress: () async {
                    final success = await authNotifier.signUp();
                    if (success) {
                      context.go(Routes.home);
                    }
                  },
                  buttonColor: AppColors.kPrimary,
                ).padBottom(15),
                // Screen Divider
                ScreenDivider(
                  color: AppColors.kPrimary,
                  text: 'OR Sign Up with',
                  indent: context.w(1),
                ).padBottom(context.h(4)),

                // Facebook Button
                CustomElevatedButton(
                  iconAsset: AppIcons.facebookIcon,
                  iconSize: context.h(4),
                  elevation: 0,
                  tWidth: context.w(3),
                  fontSize: context.h(2.5),
                  bWidth: context.w(95),
                  height: context.h(6.5),
                  borderRadius: context.w(3),
                  title: "Sign Up With Facebook",
                  textColor: AppColors.kWhite,
                  fontFamily: AppFonts.kLight,
                  onPress: () {},
                  buttonColor: AppColors.kBlack,
                ).padBottom(context.h(3)),

                // Google Button
                CustomElevatedButton(
                  iconAsset: AppIcons.googleIcon,
                  iconSize: context.h(4),
                  elevation: 0,
                  fontSize: context.h(2.5),
                  bWidth: context.w(95),
                  tWidth: context.w(7),
                  height: context.h(6.5),
                  borderRadius: context.w(3),
                  fontFamily: AppFonts.kLight,
                  title: "Sign Up With Google",
                  textColor: AppColors.kBlack,
                  borderSide: BorderSide(color: AppColors.kPrimary.withAlpha(100), width: context.w(0.5)),
                  onPress: () async {
                    final success = await authNotifier.signInWithGoogle();
                    if (success) {
                      context.go(Routes.home);
                      authNotifier.clearAuth();
                    }
                  },
                  buttonColor: AppColors.kTransparent,
                ).padBottom(context.h(3)),

                // Screen Bottom
                ScreenBottom(
                  question: "Already have an account?",
                  bText: "Sign In Here",
                  onTap: () => context.go(Routes.signin),
                ).centerWidget.padBottom(context.h(3)),
              ],
            ).padOnly(left: context.w(5), right: context.w(5)),
          ),
        ),
      ),
    );
  }
}
