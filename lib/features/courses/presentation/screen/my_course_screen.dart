import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/courses/data/provider/course_provider.dart';
import 'package:lms/features/courses/presentation/widget/my_course_card.dart';

class MyCoursesScreen extends ConsumerWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesProvider);

    return Scaffold(
      backgroundColor: AppColors.kWhite,
      appBar: AppBar(
        backgroundColor: AppColors.kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.kBlack),
          onPressed: () {
            context.go(Routes.home);
          },
        ),
        title: const Text('My Courses', style: AppTextStyle.kHeading),
      ),
      body: coursesAsync.when(
        data: (allCourses) {
          // Filter only enrolled courses (progress > 0)
          final myCourses = allCourses.where((course) => course.progress > 0).toList();

          if (myCourses.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            //padding: EdgeInsets.only(top: context.h(1.75), bottom: context.h(2)),
            itemCount: myCourses.length,
            separatorBuilder: (context, index) => SizedBox(height: context.h(0.5)),
            itemBuilder: (context, index) {
              return MyCourseCard(course: myCourses[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: AppColors.kRed, size: context.h(5)),
              SizedBox(height: context.h(2)),
              Text('Error: $error'),
              SizedBox(height: context.h(2)),
              ElevatedButton(
                onPressed: () => ref.invalidate(coursesProvider),
                child: const Text('Retry', style: AppTextStyle.kBodyLarge),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: AppColors.kGrey),
          const SizedBox(height: 16),
          Text(
            'No courses yet',
            style: AppTextStyle.kBodyLarge.copyWith(
              fontSize: context.h(3.5),
              fontWeight: FontWeight.w600,
              color: AppColors.kGrey,
            ),
          ),
          SizedBox(height: context.h(1)),
          Text(
            'Enroll in courses to see them here',
            style: AppTextStyle.kBodyLarge.copyWith(
              fontSize: context.h(3.5),
              fontWeight: FontWeight.w600,
              color: AppColors.kGrey,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.h(3)),
          ElevatedButton(
            onPressed: () => context.go(Routes.home),
            child: const Text('Browse Courses', style: AppTextStyle.kBodyLarge),
          ),
        ],
      ),
    );
  }
}
