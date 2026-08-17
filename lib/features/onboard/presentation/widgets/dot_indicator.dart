import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:Edvance/core/constants/app_colors.dart';
import 'package:Edvance/features/onboard/data/lists/onboard_list.dart';

class DotsIndicator extends StatelessWidget {
  final int currentIndex;

  const DotsIndicator({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        onBoardingContents.length,
        (i) => AnimatedContainer(
          width: context.w(1.5),
          height: context.h(0.75),
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: i == currentIndex ? AppColors.kPrimary : AppColors.kGrey,
          ),
        ).padOnly(right: context.w(1.5), top: context.h(3), bottom: context.h(5)),
      ),
    );
  }
}
