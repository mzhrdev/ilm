import 'package:Edvance/core/constants/app_colors.dart';
import 'package:Edvance/core/presentation/widgets/custom_elevated_button.dart';
import 'package:Edvance/core/routing/app_routing.dart';
import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TwoButtonRow extends StatelessWidget {
  const TwoButtonRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomElevatedButton(
          elevation: 0,
          borderRadius: context.h(1.2),
          buttonColor: AppColors.kPrimary,
          height: context.h(6.4),
          bWidth: context.w(43.6),
          title: 'SIGN IN',
          onPress: () => context.go(Routes.signin),
        ),
        CustomElevatedButton(
          elevation: 0,
          borderRadius: context.h(1.2),
          buttonColor: AppColors.kTransparent,
          height: context.h(6.4),
          bWidth: context.w(43.6),
          borderSide: BorderSide(color: AppColors.kPrimary),
          textColor: AppColors.kPrimary,

          title: 'SIGN UP',
          onPress: () => context.go(Routes.signup),
        ),
      ],
    );
  }
}
