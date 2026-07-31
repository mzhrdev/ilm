import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/custom_safe_area.dart';
import 'package:lms/features/mainTab/data/list/destination_list.dart';

class MainTabScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const MainTabScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CustomSafeArea(
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar:
            // Bottom Navigation Bar
            NavigationBar(
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              labelPadding: EdgeInsets.only(bottom: context.h(2)),
              surfaceTintColor: AppColors.kTransparent,
              indicatorShape: CircleBorder(),
              indicatorColor: AppColors.kTransparent,
              backgroundColor: AppColors.kPrimary,
              height: context.h(7.5),

              // Control label colors
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppTextStyle.kBodyMedium.copyWith(color: AppColors.kWhite);
                }
                return TextStyle(color: AppColors.kGrey.withAlpha(100));
              }),
              destinations: destination
                  .map(
                    (d) => NavigationDestination(
                      selectedIcon: Icon(d.icon, color: AppColors.kWhite, size: context.h(3.5)),
                      label: d.label,
                      icon: Icon(d.icon, color: AppColors.kGrey.withAlpha(170), size: context.h(3.5)),
                    ).padTop(context.h(2)),
                  )
                  .toList(),
              onDestinationSelected: (index) =>
                  navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
              selectedIndex: navigationShell.currentIndex,
            ),
      ),
    );
  }
}
