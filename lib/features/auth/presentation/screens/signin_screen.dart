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
import 'package:lms/core/presentation/widgets/custom_text_button.dart';
import 'package:lms/core/presentation/widgets/custom_text_field.dart';
import 'package:lms/core/presentation/widgets/snackbar.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/auth/data/providers/auth_provider.dart';
import 'package:lms/features/auth/presentation/widgets/screen_bottom.dart';
import 'package:lms/features/auth/presentation/widgets/screen_divider.dart';

class SigninScreen extends ConsumerWidget {
  const SigninScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);
    final authNotifier = ref.read(authProvider.notifier);
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.kWhite,
        body: SingleChildScrollView(
          child: Form(
            key: auth.signinFormKey,
            child: Column(
              children: [
                Center(
                  child: Text("Sign In", style: AppTextStyle.kHeading.copyWith(fontSize: context.h(4.5))),
                ),
                // Email Text
                Text(
                  "Email",
                  style: AppTextStyle.kBodyMedium,
                ).leftAlign.padOnly(top: context.w(10), bottom: context.h(0.5)),

                // Email Text Field
                CustomTextField(
                  cursorColor: AppColors.kPrimary,
                  borderWidth: context.w(0.5),
                  controller: auth.authEmailController,
                  hintText: "...@gmail.com",
                  focusedBorderColor: AppColors.kPrimary,
                  enabledBorderColor: AppColors.kPrimary.withAlpha(100),
                  labelText: null,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: FieldValidator.email(),
                ),

                // Password Text
                Text(
                  "Password",
                  style: AppTextStyle.kBodyMedium,
                ).leftAlign.padOnly(top: context.w(5), bottom: context.h(0.5)),

                // Password Text Field
                CustomPasswordTextField(
                  cursorColor: AppColors.kPrimary,
                  focusedBorderColor: AppColors.kPrimary,
                  controller: auth.authPasswordController,
                  hintText: "xX1@...",
                  labelText: null,
                  borderWidth: context.w(0.5),
                  enabledBorderColor: AppColors.kPrimary.withAlpha(100),
                  keyboardType: TextInputType.text,
                  textInputAction: TextInputAction.done,
                  validator: FieldValidator.password(),
                ),

                // Forgot Password
                CustomTextButton(
                  text: "Forget Password?",
                  color: AppColors.kSecondary,
                  fontSize: context.h(1.5),
                  onPressed: () => context.replace(Routes.resetPassEmail),
                ).rightAlign.padOnly(top: context.h(2), bottom: context.h(10)),

                // Signin Button
                CustomElevatedButton(
                  loading: auth.isLoading,
                  elevation: 0,
                  bWidth: context.w(95),
                  borderRadius: context.w(3),
                  fontSize: context.h(3),
                  fontFamily: AppFonts.kLight,
                  height: context.h(6.5),
                  title: "SIGN IN",
                  onPress: () async {
                    final success = await authNotifier.signIn();
                    if (success) {
                      authNotifier.clearAuth();
                      context.go(Routes.home);
                    } else {
                      ShowSnackbar1.error(context, auth.errorMessage.toString());
                    }
                  },
                  buttonColor: AppColors.kPrimary,
                ).padBottom(context.h(3)),

                // Screen Divider
                ScreenDivider(
                  color: AppColors.kPrimary,
                  text: 'OR Signin with',
                  indent: context.w(1),
                ).padBottom(context.h(5)),

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
                  title: "Sign In With Facebook",
                  textColor: AppColors.kWhite,
                  fontFamily: AppFonts.kLight,
                  onPress: () {
                    ShowSnackbar1.error(context,'Facebook Implementation Not Available!');
                  },
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
                  title: "Sign In With Google",
                  textColor: AppColors.kBlack,
                  borderSide: BorderSide(color: AppColors.kPrimary.withAlpha(100), width: context.w(0.5)),
                  onPress: () async {
                    final success = await authNotifier.signInWithGoogle();
                    if (success) {
                      context.go(Routes.home);
                      
                    }
                  },
                  buttonColor: AppColors.kTransparent,
                ).padBottom(context.h(3)),

                // Screen Bottom
                ScreenBottom(
                  question: "Don't have an account?",
                  bText: "Sign Up Here",
                  onTap: () {
                    authNotifier.clearAuth(); // ADD
                    context.go(Routes.signup);
                  },
                ).centerWidget,
              ],
            ).padOnly(left: context.w(6), right: context.w(6)),
          ),
        ),
      ),
    );
  }
}
