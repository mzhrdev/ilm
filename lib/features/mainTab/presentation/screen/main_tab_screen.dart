import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/features/mainTab/data/list/destination_list.dart';

class MainTabScreen extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const MainTabScreen({super.key, required this.navigationShell});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar:
          // Bottom Navigation Bar
          NavigationBar(
            labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
            surfaceTintColor: AppColors.kBlack,
            indicatorShape: CircleBorder(),
            indicatorColor: AppColors.kTransparent,
            backgroundColor: AppColors.kSecondary,
            height: context.h(7.5),
            destinations: destination
                .map(
                  (d) => NavigationDestination(
                    label: d.label,
                    icon: Icon(d.icon, color: AppColors.kWhite, size: context.w(8)).centerWidget,
                  ),
                )
                .toList(),
            onDestinationSelected: (index) =>
                navigationShell.goBranch(index, initialLocation: index == navigationShell.currentIndex),
            selectedIndex: navigationShell.currentIndex,
          ),
    );
  }
}
