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
                decoration: const BoxDecoration(color: AppColors.kGrey),
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

                // Rating and Course Status
                Row(
                  children: [
                    const Icon(Icons.star, size: 16, color: AppColors.kAmber),

                    SizedBox(width: context.w(2)),

                    Text(courseEnrollment.rating.toString(), style: AppTextStyle.kBodySmall),

                    const Spacer(),

                    _buildCourseStatus(context),
                  ],
                ),
              ],
            ).padAll(context.w(3)),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseStatus(BuildContext context) {
    // User is already enrolled.
    if (courseEnrollment.enrollment != null) {
      return _buildStatusBadge(context, label: 'Enrolled', icon: Icons.check_circle_outline);
    }

    // Course is free.
    if (courseEnrollment.course.price == 0) {
      return _buildStatusBadge(context, label: 'Free', icon: Icons.card_giftcard_outlined);
    }

    // Course is paid but user is not enrolled.
    return _buildStatusBadge(
      context,
      label: '\$${courseEnrollment.course.price.toStringAsFixed(0)}',
      icon: Icons.local_offer_outlined,
    );
  }

  Widget _buildStatusBadge(BuildContext context, {required String label, required IconData icon}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: context.w(2.5), vertical: context.h(0.4)),
      decoration: BoxDecoration(
        color: AppColors.kGrey.withAlpha(80),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: context.h(1.7), color: AppColors.kBlack),
          SizedBox(width: context.w(1)),
          Text(label, style: AppTextStyle.kBodySmall.copyWith(fontWeight: FontWeight.w600)),
        ],
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
          if (loadingProgress == null) {
            return child;
          }

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
    }

    return Image.asset(
      AppImages.graphic_design,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }
}
