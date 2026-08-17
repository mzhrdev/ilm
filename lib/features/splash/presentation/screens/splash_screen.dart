import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Edvance/core/constants/app_assets.dart';
import 'package:Edvance/core/constants/app_colors.dart';
import 'package:Edvance/core/routing/app_routing.dart';
import 'package:Edvance/features/auth/data/providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      final isLoggedIn = ref.read(authProvider.notifier).isLoggedIn();

      if (isLoggedIn) {
        context.go(Routes.home);
      } else {
        context.go(Routes.onBoard);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: Center(child: Image.asset(AppImages.splashImage)),
    );
  }
}
