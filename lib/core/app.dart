import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/calls/presentation/widget/call_listener_wrapper.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'lms',
      debugShowCheckedModeBanner: false,
      routerConfig: ref.watch(routerProvider),
      // 👉 ADD THIS BUILDER RIGHT HERE:
      // This safely places your call overlay inside the MaterialApp environment
      builder: (context, child) {
        return CallListenerWrapper(child: child!);
      },
      theme: ThemeData(
        colorSchemeSeed: Ext.getMaterialColor(AppColors.kWhite),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(AppColors.kTransparent), // solid color
            foregroundColor: WidgetStatePropertyAll(AppColors.kTransparent), // text/icon color
          ),
        ),
        dialogTheme: DialogThemeData(
          surfaceTintColor: AppColors.kTransparent,
          backgroundColor: AppColors.kWhite,
        ),
        iconTheme: const IconThemeData(color: AppColors.kSecondary),
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.kWhite,
          surfaceTintColor: AppColors.kTransparent,
        ),
        cardTheme: CardThemeData(surfaceTintColor: AppColors.kTransparent, color: AppColors.kWhite),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.kWhite,
          surfaceTintColor: AppColors.kTransparent,
        ),
        drawerTheme: const DrawerThemeData(surfaceTintColor: AppColors.kTransparent),
        popupMenuTheme: const PopupMenuThemeData(
          surfaceTintColor: AppColors.kTransparent,
          color: AppColors.kWhite,
        ),
        scaffoldBackgroundColor: AppColors.kWhite,
      ),
    );
  }
}
