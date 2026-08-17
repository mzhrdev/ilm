import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Edvance/core/constants/app_colors.dart';
import 'package:Edvance/core/constants/app_text_styles.dart';
import 'package:Edvance/core/presentation/widgets/custom_elevated_button.dart';
import 'package:Edvance/core/presentation/widgets/custom_safe_area.dart';
import 'package:Edvance/core/presentation/widgets/custom_text_button.dart';
import 'package:Edvance/core/routing/app_routing.dart';
import 'package:Edvance/features/onboard/data/lists/onboard_list.dart';
import 'package:Edvance/features/onboard/data/provider/onboard_provider.dart';
import 'package:Edvance/features/onboard/presentation/widgets/dot_indicator.dart';
import 'package:Edvance/features/onboard/presentation/widgets/two_button_row.dart';

class OnboardScreen extends ConsumerWidget {
  const OnboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final onboardState = ref.watch(onBoardingProvider);
    final onboardNotifier = ref.read(onBoardingProvider.notifier);
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.kWhite,
        body: PageView.builder(
          controller: onboardState.controller,
          onPageChanged: onboardNotifier.updateCurrentPage,
          itemCount: onBoardingContents.length,
          itemBuilder: (BuildContext context, int index) {
            final content = onBoardingContents[index];
            final isLast = index == onBoardingContents.length - 1;
            return Column(
              children: [
                // Skip Button
                isLast
                    ? SizedBox(height: context.h(6.25))
                    : CustomTextButton(
                        text: "Skip",
                        onPressed: () => onboardState.controller.jumpToPage(onBoardingContents.length - 1),
                        color: AppColors.kBlack,
                        bgColor: AppColors.kGrey.withAlpha(100),
                      ).topRightAlign.padAll(8),
                // Top Image
                SizedBox(
                  height: context.h(40),
                  width: context.w(80),
                  child: Image(image: AssetImage(content.icon)),
                ),
                // Title
                Text(
                  content.title,
                  style: AppTextStyle.kHeading,
                  textAlign: TextAlign.center,
                ).padOnly(top: context.h(1), bottom: context.h(1)),

                // Subtitle
                Text(content.subTitle, style: AppTextStyle.kSectionTitle, textAlign: TextAlign.center),
                // Dots Indicator
                DotsIndicator(currentIndex: onboardState.currentPage),

                // Next/Get Started Button
                isLast
                    ? TwoButtonRow()
                    : CustomElevatedButton(
                        elevation: 0,
                        borderRadius: context.h(1.2),
                        buttonColor: AppColors.kPrimary,
                        height: context.h(6.4),
                        bWidth: context.w(53.6),
                        title: 'CONTINUE',
                        onPress: () {
                          if (isLast) {
                            context.go(Routes.signin);
                          } else {
                            onboardNotifier.nextPage();
                          }
                        },
                      ),
              ],
            ).padOnly(left: context.w(3), right: context.w(3));
          },
        ),
      ),
    );
  }
}
