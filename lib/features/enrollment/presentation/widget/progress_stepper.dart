import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';

class ProgressStepper extends StatelessWidget {
  final int currentStep;
  final List<String> steps;

  const ProgressStepper({super.key, required this.currentStep, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: context.h(3), horizontal: context.w(2)),
      decoration: BoxDecoration(
        color: AppColors.kGrey.withAlpha(90),
        borderRadius: BorderRadius.circular(context.w(4)),
      ),
      child: Stack(
        children: [
          // Background line connecting all steps
          Positioned(
            left: 40,
            right: 40,
            top: 20,
            child: Row(
              children: [
                Expanded(
                  child: Container(height: context.h(0.5), color: AppColors.kGrey),
                ),
                Expanded(
                  child: Container(height: context.h(0.5), color: AppColors.kGrey),
                ),
              ],
            ),
          ),
          // Active line showing progress
          Positioned(
            left: 40,
            right: 40,
            top: 20,
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: context.h(0.5),
                    color: currentStep > 1 ? AppColors.kBlack : AppColors.kTransparent,
                  ),
                ),
                Expanded(
                  child: Container(
                    height: context.h(0.5),
                    color: currentStep > 2 ? AppColors.kBlack : AppColors.kTransparent,
                  ),
                ),
              ],
            ),
          ),
          // Step indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (index) {
              final stepNumber = index + 1;
              final isActive = stepNumber <= currentStep;

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.kBlack : AppColors.kGrey,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$stepNumber',
                          style: AppTextStyle.kBodyLarge.copyWith(
                            color: isActive ? AppColors.kWhite : AppColors.kBlack.withAlpha(150),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: context.h(1)),
                    Text(
                      steps[index],
                      style: AppTextStyle.kBodySmall.copyWith(
                        color: isActive ? AppColors.kBlack : AppColors.kBlack.withAlpha(100),
                        fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
