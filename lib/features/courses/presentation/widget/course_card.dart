// lib/features/home/presentation/widgets/course_card.dart

import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_assets.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/routing/app_routing.dart';

import '../../data/model/course_enrollment_model.dart';

class CourseCard extends StatelessWidget {
  final CourseEnrollmentModel courseEnrollment;

  const CourseCard({super.key, required this.courseEnrollment});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(Routes.courseDetail.replaceAll(':id', courseEnrollment.id)),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(color: AppColors.kBlack.withAlpha(30), blurRadius: 10, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(color: AppColors.kGrey),
                child: _buildThumbnail(),
              ),
            ),
            // Course Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  courseEnrollment.title,
                  style: AppTextStyle.kBodyMedium.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.h(0.35)),
                Text(
                  'By ${courseEnrollment.instructorName}',
                  style: AppTextStyle.kBodySmall.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.h(1.25)),
                // Rating and Progress
                Row(
                  children: [
                    Icon(Icons.star, size: 16, color: AppColors.kAmber),
                    SizedBox(width: context.w(2)),
                    Text(courseEnrollment.rating.toString(), style: AppTextStyle.kBodySmall),
                    const Spacer(),
                    Text(
                      '${(courseEnrollment.progress * 100).toInt()}% Done',
                      style: AppTextStyle.kBodySmall.copyWith(fontSize: context.h(1.25)),
                    ),
                  ],
                ),
                SizedBox(height: context.h(0.5)),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: courseEnrollment.progress,
                    minHeight: 4,
                    backgroundColor: AppColors.kGrey.withAlpha(400),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.kBlack),
                  ),
                ),
              ],
            ).padAll(context.w(3)),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    if (courseEnrollment.thumbnailUrl.isNotEmpty) {
      return Image.network(
        courseEnrollment.thumbnailUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(child: Icon(Icons.image, size: 40, color: Colors.grey));
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
            ),
          );
        },
      );
    } else {
      return Image.asset(
        AppImages.graphic_design,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
      );
    }
  }
}
