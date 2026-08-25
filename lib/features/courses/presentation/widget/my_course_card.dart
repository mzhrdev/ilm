import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_assets.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/courses/data/model/course_enrollment_model.dart';

class MyCourseCard extends StatelessWidget {
  final CourseEnrollmentModel courseEnrollment;
  const MyCourseCard({super.key, required this.courseEnrollment});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final id = courseEnrollment.id;
        if (id.isEmpty) {
          debugPrint('Course ID is empty');
          return;
        }
        context.push(Routes.courseDetail.replaceAll(':id', id));
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: context.w(4), vertical: context.h(1)),
        padding: EdgeInsets.all(context.w(3)),
        decoration: BoxDecoration(color: AppColors.kGrey, borderRadius: BorderRadius.circular(context.w(5))),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: context.w(17),
              height: context.h(6.5),
              decoration: BoxDecoration(
                color: AppColors.kBlack.withAlpha(100),
                borderRadius: BorderRadius.circular(context.w(3)),
              ),
              child: _buildThumbnail(context),
            ),
            SizedBox(width: context.w(4)),

            // Course Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    courseEnrollment.title,
                    style: AppTextStyle.kBodyLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: context.h(0.75)),
                  // Instructor Name
                  Text(
                    'By ${courseEnrollment.instructorName}',
                    style: AppTextStyle.kBodyMedium.copyWith(color: AppColors.kBlack.withAlpha(90)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: context.h(0.75)),

                  // Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: courseEnrollment.progress,
                      minHeight: 4,
                      backgroundColor: AppColors.kWhite,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.kBlack),
                    ),
                  ),
                  SizedBox(height: context.h(0.75)),

                  // Progress Percentage
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '${(courseEnrollment.progress * 100).toInt()}% Done',
                      style: AppTextStyle.kBodySmall.copyWith(color: AppColors.kBlack.withAlpha(150)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  // Thumbnail Widget
  Widget _buildThumbnail(BuildContext context) {
    final thumbnailUrl = courseEnrollment.thumbnailUrl;

    if (thumbnailUrl.isNotEmpty) {
      return Image.network(
        thumbnailUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) {
          return Center(
            child: Icon(Icons.image, size: context.h(5), color: AppColors.kGrey),
          );
        },
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;

          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      );
    }

    return Image.asset(
      AppImages.graphic_design,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.fill,
    );
  }
}
