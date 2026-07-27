import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_assets.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/routing/app_routing.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // 2. Navigate to the main/home screen after 3 seconds
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        context.go(Routes.onBoard);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kWhite,
      body: Center(child: Image(image: AssetImage(AppImages.splashImage))),
    );
  }
}
