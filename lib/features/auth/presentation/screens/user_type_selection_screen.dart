import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/presentation/widgets/custom_elevated_button.dart';
import 'package:lms/core/presentation/widgets/custom_elevated_drop_down_menu.dart';
import 'package:lms/core/presentation/widgets/custom_safe_area.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/auth/data/providers/auth_provider.dart';

class UserTypeSelectionScreen extends ConsumerWidget {
  const UserTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authProvider);
    //final userType = state.userTypeController.text;
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.kWhite,
        appBar: AppBar(
          backgroundColor: AppColors.kWhite,
          title: Text("User Type Selection Screen"),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Screen Description Text
            Text("Please select what is your current status at campus").padAll(context.w(5)),
            // Drop Down Menu to select Type
            CustomElevatedDropDownMenuButton(
              hintText: "Select User Type",
              elevation: 0,
              enabledBorderColor: AppColors.kBlack,
              textController: state.userTypeController,
              textFontColor: AppColors.kBlack,
              width: context.w(80),
              dropdownMenuEntries: [
                DropdownMenuEntry(value: 0, label: "Admin"),
                DropdownMenuEntry(value: 1, label: "Student"),
                DropdownMenuEntry(value: 2, label: "Teacher"),
              ],
              onSelected: (_) {},
            ),
            // Gap b/w
            SizedBox(height: context.h(5)),
            // Button to submit and proceed
            CustomElevatedButton(
              bWidth: context.w(85),
              borderRadius: context.w(5),
              elevation: 0,
              buttonColor: AppColors.kPrimary,
              title: "Next",
              onPress: () {
                context.go(Routes.signin);
                state.userTypeController.clear();
              },
            ),
          ],
        ),
      ),
    );
  }
}
