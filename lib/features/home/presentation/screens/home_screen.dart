import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/custom_icon_button.dart';
import 'package:lms/core/presentation/widgets/custom_safe_area.dart';
import 'package:lms/core/presentation/widgets/custom_text_button.dart';
import 'package:lms/core/presentation/widgets/custom_text_field.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/auth/data/providers/auth_provider.dart';
import 'package:lms/features/courses/data/model/course_model.dart';
import 'package:lms/features/home/data/providers/home_provider.dart';

import '../../../courses/data/provider/course_provider.dart';
import '../../../courses/presentation/widget/course_card.dart';
import '../../data/providers/category_provider.dart';
import '../widgets/category_chip.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final home = ref.watch(homeProvider);
    final user = ref.watch(currentUserProvider);
    final categories = ref.watch(categoriesProvider);
    final coursesAsync = ref.watch(coursesProvider);

    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(child: _buildHeader(context, user?.name ?? 'Buddy')),

            // Search Bar
            SliverToBoxAdapter(child: _buildSearchBar(home.homeSearchController, context)),

            // Categories
            SliverToBoxAdapter(child: _buildCategories(categories, context)),

            // Continue Watching Section
            SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Continue Watching', style: AppTextStyle.kBodyLarge),
                  CustomTextButton(text: 'See All', onPressed: null),
                ],
              ).padOnly(top: context.h(1), bottom: context.h(2)),
            ),

            // Course Grid
            coursesAsync.when<Widget>(
              data: (allCourses) {
                final continueWatching = allCourses.where((course) => course.progress > 0).toList();

                if (continueWatching.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        'No courses in progress yet.',
                        style: AppTextStyle.kBodyLarge,
                      ).padAll(context.h(4)),
                    ),
                  );
                }

                return _buildCourseGrid(continueWatching, context);
              },
              loading: () =>
                  SliverToBoxAdapter(child: Center(child: CircularProgressIndicator().padAll(context.h(9)))),
              error: (error, stack) => SliverToBoxAdapter(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 48),
                      SizedBox(height: context.h(4)),
                      Text('Error: $error'),
                      SizedBox(height: context.h(8)),
                      ElevatedButton(
                        onPressed: () => ref.invalidate(coursesProvider),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ).padHrz(context.w(3.5)),
    );
  }

  String _firstName(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'there';
    final trimmed = fullName.trim();
    final spaceIndex = trimmed.indexOf(' ');
    return spaceIndex == -1 ? trimmed : trimmed.substring(0, spaceIndex);
  }

  // Home Screen Header
  Widget _buildHeader(BuildContext context, String? userName) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Welcome, ${_firstName(userName)}', style: AppTextStyle.kHeading),
        Row(
          children: [
            // Settings Button
            CustomIconButton(
              onTap: () => context.push(Routes.settings),
              icon: Icons.settings,
              iconColor: AppColors.kPrimary,
            ),
            // Notification Button
            CustomIconButton(
              onTap: () => context.push(Routes.notification),
              icon: Icons.notifications,
              iconColor: AppColors.kPrimary,
            ),
          ],
        ),
      ],
    ).padAll(context.w(2.5));
  }

  // Search Bar
  Widget _buildSearchBar(TextEditingController controller, BuildContext context) {
    return CustomTextField(
      controller: controller,
      hintText: 'Search Here',
      labelText: null,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.search,
      isPrefixIconEnabled: true,
      preFixIcon: Icons.search,
      borderRadius: context.w(5),
      fillColor: AppColors.kWhite.withAlpha(100),
      validator: FieldValidator.alphaNumeric(),
      enabledBorderColor: AppColors.kGrey,
      focusedBorderColor: AppColors.kGrey,
    );
  }

  // Categories Method
  Widget _buildCategories(List<String> categories, BuildContext context) {
    return SizedBox(
      height: context.h(7),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: categories.length,
        separatorBuilder: (_, __) => SizedBox(width: context.w(2)),
        itemBuilder: (context, index) {
          return CategoryChip(label: categories[index], isSelected: index < 3, onTap: () {});
        },
      ),
    );
  }

  // Build Course Grid Method
  Widget _buildCourseGrid(List<CourseModel> courses, BuildContext context) {
    return SliverGrid(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      delegate: SliverChildBuilderDelegate((context, index) {
        final course = courses[index];
        return CourseCard(course: course);
      }, childCount: courses.length),
    );
  }
}
