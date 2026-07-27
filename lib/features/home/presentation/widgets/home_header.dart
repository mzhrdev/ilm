import 'package:flutter/material.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/custom_icon_button.dart';

class HomeHeader extends StatelessWidget {
  final String userName;
  const HomeHeader({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Welcome Text
        Text("Welcome $userName", style: AppTextStyle.kSectionTitle),
        // Icon Button
        Row(
          children: [
            // Settings Button
            CustomIconButton(onTap: () {}, icon: Icons.settings),
            // Notification Button
            CustomIconButton(onTap: () {}, icon: Icons.notifications),
          ],
        ),
      ],
    );
  }
}
