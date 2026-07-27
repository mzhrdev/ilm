import 'package:flutter/material.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class CustomCircularProgressIndicator extends StatelessWidget {
  const CustomCircularProgressIndicator({
    super.key,
    required this.height,
    required this.width,
    required this.selectedProgressColor,
    required this.unSelectedProgressColor,
    required this.totalSteps,
    required this.currentSteps,
    required this.widget,
  });
  final double? height;
  final double? width;
  final Color? selectedProgressColor;
  final Color? unSelectedProgressColor;
  final int totalSteps;
  final int currentSteps;
  final Widget? widget;
  @override
  Widget build(BuildContext context) {
    return CircularStepProgressIndicator(
      height: height,
      width: width,
      selectedColor: selectedProgressColor,
      unselectedColor: unSelectedProgressColor,
      roundedCap: (index, _) => true,
      padding: 0,
      totalSteps: totalSteps,
      currentStep: currentSteps,
      child: widget,
    );
  }
}
