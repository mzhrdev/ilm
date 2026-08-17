import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Edvance/core/constants/app_colors.dart';

// PROVIDER
final onBoardingProvider = StateNotifierProvider<OnBoardingNotifier, OnBoardingState>(
  (ref) => OnBoardingNotifier(),
);

// STATE
class OnBoardingState {
  final int currentPage;
  final PageController controller;

  OnBoardingState({required this.currentPage, required this.controller});

  OnBoardingState copyWith({int? currentPage, PageController? controller}) {
    return OnBoardingState(
      currentPage: currentPage ?? this.currentPage,
      controller: controller ?? this.controller,
    );
  }
}

// NOTIFIER
class OnBoardingNotifier extends StateNotifier<OnBoardingState> {
  OnBoardingNotifier() : super(OnBoardingState(currentPage: 0, controller: PageController()));

  // update current page method
  void updateCurrentPage(int val) {
    state = state.copyWith(currentPage: val);
  }

  // scroll to next page method
  void nextPage() {
    state.controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  // scroll to previous page method
  void previousPage() {
    state.controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
  }

  // animated dots when moving from one page to other
  AnimatedContainer buildDots({required int index, required BuildContext context}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        color: state.currentPage == index ? AppColors.kPrimary : AppColors.kSecondary,
      ),
      margin: EdgeInsets.symmetric(horizontal: context.w(2)),
      height: 2,
      width: context.w(20),
      curve: Curves.easeIn,
    );
  }
}
