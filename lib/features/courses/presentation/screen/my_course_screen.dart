import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/custom_elevated_button.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/courses/data/provider/course_provider.dart';
import 'package:lms/features/courses/presentation/widget/my_course_card.dart';

class MyCoursesScreen extends ConsumerWidget {
  const MyCoursesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final myCoursesState = ref.watch(myCoursesProvider);

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

      body: myCoursesState.when(
        data: (courses) {
          if (courses.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            padding: EdgeInsets.symmetric(vertical: context.h(1)),

            itemCount: courses.length,

            separatorBuilder: (context, index) {
              return SizedBox(height: context.h(0.5));
            },

            itemBuilder: (context, index) {
              final courseEnrollment = courses[index];

              return MyCourseCard(courseEnrollment: courseEnrollment);
            },
          );
        },

        loading: () {
          return const Center(child: CircularProgressIndicator());
        },

        error: (error, stackTrace) {
          return Center(
            child: Padding(
              padding: EdgeInsets.all(context.w(5)),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(Icons.error_outline, color: AppColors.kRed, size: context.h(5)),

                  SizedBox(height: context.h(2)),

                  Text(error.toString(), textAlign: TextAlign.center, style: AppTextStyle.kBodyLarge),

                  SizedBox(height: context.h(2)),

                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(myCoursesProvider);
                    },

                    child: const Text('Retry', style: AppTextStyle.kBodyLarge),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: context.h(8), color: AppColors.kGreen),
          SizedBox(height: context.h(2)),
          Text(
            'No courses yet',
            style: AppTextStyle.kBodyLarge.copyWith(
              fontSize: context.h(3),
              fontWeight: FontWeight.w600,
              color: AppColors.kBlack,
            ),
          ),
          SizedBox(height: context.h(1)),
          Text(
            'Enroll in courses to see them here',
            textAlign: TextAlign.center,

            style: AppTextStyle.kBodyMedium.copyWith(color: AppColors.kRed),
          ),
          SizedBox(height: context.h(3)),
          CustomElevatedButton(
            onPress: () {
              context.go(Routes.home);
            },
            title: 'Browse Courses',
          ),
        ],
      ),
    );
  }
}
