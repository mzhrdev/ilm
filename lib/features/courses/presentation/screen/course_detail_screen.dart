import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/custom_elevated_button.dart';
import 'package:lms/core/presentation/widgets/custom_safe_area.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/auth/data/providers/current_user_provider.dart';
import 'package:lms/features/courses/data/model/lesson_model.dart';
import 'package:lms/features/enrollment/data/model/enrollment_model.dart';
import 'package:lms/features/enrollment/data/provider/enrollment_provider.dart';
import 'package:lms/features/home/presentation/widgets/review_card.dart';

import '../../../home/presentation/widgets/skill_chip.dart';
import '../../data/model/course_model.dart';
import '../../data/provider/course_provider.dart';
import '../widget/course_info_card.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  final String courseId;
  const CourseDetailScreen({super.key, required this.courseId});
  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Init State Method
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  // Dispose Method
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final courseAsync = ref.watch(courseDetailProvider(widget.courseId));
    final userId = ref.watch(currentUserProvider)?.id;
    final enrollmentAsync = ref.watch(enrollmentLookupProvider((courseId: widget.courseId, userId: userId)));

    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.kWhite,
        body: courseAsync.when(
          // Course Detail Content
          data: (course) => _buildCourseDetailContent(course),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error Icon
                Icon(Icons.error_outline, color: AppColors.kCallEndB, size: context.w(15)),
                SizedBox(height: context.h(3)),
                // Error Message
                Text('Error: $error'),
                SizedBox(height: context.h(6)),

                ElevatedButton(
                  onPressed: () {
                    ref.invalidate(courseDetailProvider(widget.courseId));
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),

        bottomNavigationBar: _buildEnrollButton(courseAsync.value, enrollmentAsync),
      ),
    );
  }

  // Enrollment Button Widget
  Widget _buildEnrollButton(CourseModel? course, AsyncValue<EnrollmentModel?> enrollmentAsync) {
    if (course == null) {
      return const SizedBox.shrink();
    }

    final isEnrolled = enrollmentAsync.value != null;
    final isCheckingEnrollment = enrollmentAsync.isLoading;

    String buttonText;

    if (isCheckingEnrollment) {
      buttonText = 'CHECKING...';
    } else if (isEnrolled) {
      buttonText = 'ENROLLED';
    } else {
      buttonText = 'GET ENROLL';
    }

    return Container(
      padding: EdgeInsets.all(context.w(5)),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.w(5)),
        color: AppColors.kWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.kBlack.withValues(alpha: 0.1),
            blurRadius: context.h(1),
            offset: const Offset(2, -3),
          ),
        ],
      ),

      child: CustomElevatedButton(
        buttonColor: AppColors.kBlack,
        buttonDisabledColor: isEnrolled ? AppColors.kGrey : AppColors.kGrey.withAlpha(150),
        title: buttonText,
        borderRadius: context.w(2.5),
        textColor: isEnrolled ? AppColors.kBlack : AppColors.kWhite,
        onPress: isCheckingEnrollment
            ? null
            : isEnrolled
            ? null
            : () {
                final userId = ref.read(currentUserProvider)?.id ?? '';
                if (userId.isEmpty) {
                  return;
                }
                ref.read(enrollmentProvider.notifier).initializeFromCourse(course, userId: userId);
                context.push(Routes.enrollmentScreen);
              },
      ),
    ).padAll(context.w(3));
  }

  Widget _buildCourseDetailContent(CourseModel course) {
    return Column(
      children: [
        Stack(
          children: [
            // Video Thumbnail
            Container(
              height: context.h(35),
              width: double.infinity,
              color: AppColors.kGrey,
              child: Container(
                width: context.w(20),
                height: context.h(10),
                decoration: BoxDecoration(color: AppColors.kWhite, shape: BoxShape.circle),
                child: Icon(Icons.play_arrow, color: AppColors.kBlack, size: context.h(5)),
              ).centerWidget,
            ),
            Positioned(
              top: context.h(2),
              left: context.w(4),
              right: context.w(4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: EdgeInsets.all(context.w(2.18)),
                      decoration: BoxDecoration(
                        color: AppColors.kWhite,
                        borderRadius: BorderRadius.circular(context.w(2.25)),
                      ),
                      child: Icon(Icons.arrow_back_ios_new, size: context.h(2.35)),
                    ),
                  ),
                  // Bookmark Button
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      padding: EdgeInsets.all(context.w(2.18)),
                      decoration: BoxDecoration(
                        color: AppColors.kWhite,
                        borderRadius: BorderRadius.circular(context.w(2.25)),
                      ),
                      child: Icon(Icons.bookmark_border, size: context.h(2.35)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Expanded(
          child: CustomScrollView(
            slivers: [
              // Tabs
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverHeaderDelegate(
                  minExtent: 50,
                  maxExtent: 50,
                  child: TabBar(
                    controller: _tabController,
                    labelColor: Colors.black,
                    unselectedLabelColor: Colors.grey,
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                    indicatorColor: Colors.black,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Lessons'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                ),
              ),

              // Tab Content
              SliverToBoxAdapter(
                child: SizedBox(
                  // This bounded height is required by TabBarView
                  height: context.h(50),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // OverView Tab
                      _buildOverviewTab(course),
                      // Lessons Tab
                      _buildLessonsTab(course),
                      // Reviews Tab
                      _buildReviewsTab(course),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(CourseModel course) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.w(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Course Main Info (Title, Teacher, Reviews, Price)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Course Title
                    Text(course.title, style: AppTextStyle.kHeading),
                    SizedBox(height: context.h(1)),
                    // Instructor Name
                    Text('By ${course.instructorName}', style: AppTextStyle.kBodyMedium),
                    SizedBox(height: context.h(2)),
                    // Reviews (Stars, Int)
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < course.rating.floor() ? Icons.star : Icons.star_border,
                            color: AppColors.kAmber,
                            size: context.w(5),
                          );
                        }),
                        const SizedBox(width: 8),
                        Text('${course.rating}', style: AppTextStyle.kBodyMedium),
                      ],
                    ),
                  ],
                ),
              ),
              // Course Price
              Text('${course.price}\$', style: AppTextStyle.kHeading),
            ],
          ),

          SizedBox(height: context.h(3.75)),

          // Description Title
          Text('Description', style: AppTextStyle.kSectionTitle.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: context.h(1.25)),
          // Description Title
          Text(course.description, style: AppTextStyle.kBodyMedium),
          SizedBox(height: context.h(2)),

          // Course Info Card
          CourseInfoCard(
            lectures: course.totalLessons,
            duration: '${course.totalDurationMinutes ~/ 60} Weeks',
            hasCertificate: true,
            discount: 10,
          ),

          SizedBox(height: context.h(2)),

          // Skills
          Text('Skills', style: AppTextStyle.kSectionTitle.copyWith(fontWeight: FontWeight.bold)),
          SizedBox(height: context.h(2)),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: course.skills.map((skill) => SkillChip(label: skill)).toList(),
          ),

          // Extra bottom padding to ensure it clears the bottom nav when scrolling
          SizedBox(height: context.h(5)),
        ],
      ),
    );
  }

  // Lessons Tab
  Widget _buildLessonsTab(CourseModel course) {
    if (course.modules.isEmpty) {
      return const Center(
        child: Text('No lessons available', style: TextStyle(color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < course.modules.length; i++)
            // Chapter Card
            _buildChapterCard(
              chapterNumber: i + 1,
              chapterTitle: course.modules[i].title,
              lessons: course.modules[i].lessons,
              isExpanded: i == 0,
            ),
          SizedBox(height: context.h(3)),
        ],
      ),
    );
  }

  Widget _buildChapterCard({
    required int chapterNumber,
    required String chapterTitle,
    required List<LessonModel> lessons,
    required bool isExpanded,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: context.h(2)),
      decoration: BoxDecoration(
        color: AppColors.kGrey.withAlpha(100),
        borderRadius: BorderRadius.circular(context.w(3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chapter Header
          Text(
            'Chapter $chapterNumber: $chapterTitle',
            style: AppTextStyle.kBodyLarge.copyWith(fontSize: context.h(2), fontWeight: FontWeight.w600),
          ).padAll(context.w(4)),
          // Lessons (if expanded)
          if (isExpanded) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            ...lessons.map((lesson) => _buildLessonItem(lesson)),
          ],
        ],
      ),
    );
  }

  Widget _buildLessonItem(LessonModel lesson) {
    return Row(
      children: [
        // Icon based on lesson type
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
          child: Icon(
            lesson.type == 'video' ? Icons.play_arrow : Icons.description,
            color: Colors.white,
            size: 18,
          ),
        ),
        const SizedBox(width: 12),
        // Lesson title
        Expanded(
          child: Text(
            lesson.title,
            style: AppTextStyle.kBodyMedium.copyWith(fontSize: context.h(1.75), color: AppColors.kBlack),
          ),
        ),
        // Lock icon if not free
        if (!lesson.isFree)
          Icon(Icons.lock_outline, size: context.h(2), color: AppColors.kBlack.withAlpha(150)),
      ],
    ).padSymmetric(horizontal: context.w(3), vertical: context.h(1.5));
  }

  Widget _buildReviewsTab(CourseModel course) {
    if (course.reviews.isEmpty) {
      return const Center(
        child: Text('No reviews yet', style: TextStyle(color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(context.w(5)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional: Show average rating summary
          Container(
            padding: EdgeInsets.all(context.w(5)),
            decoration: BoxDecoration(
              color: AppColors.kBlue,
              borderRadius: BorderRadius.circular(context.w(5)),
            ),
            child: Row(
              children: [
                // Average Rating
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.rating.toString(),
                      style: AppTextStyle.kBodyMedium.copyWith(
                        fontSize: context.h(3),
                        fontWeight: FontWeight.bold,
                        color: AppColors.kBlack,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < course.rating.floor() ? Icons.star : Icons.star_border,
                            color: AppColors.kAmber,
                            size: context.h(3),
                          );
                        }),
                      ],
                    ),
                    Text(
                      '${course.totalRatings} reviews',
                      style: AppTextStyle.kBodyLarge.copyWith(fontSize: context.h(3), color: AppColors.kGrey),
                    ),
                  ],
                ),
                const Spacer(),
                // Rating Breakdown (optional)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildRatingBar(5, 85),
                    _buildRatingBar(4, 10),
                    _buildRatingBar(3, 3),
                    _buildRatingBar(2, 1),
                    _buildRatingBar(1, 1),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: context.h(5)),
          // Reviews List
          Text(
            'All Reviews',
            style: AppTextStyle.kBodyLarge.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: context.h(4)),
          ...course.reviews.map((review) => ReviewCard(review: review)),
          SizedBox(height: context.h(40)),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, int percentage) {
    return Row(
      children: [
        Text('$stars', style: AppTextStyle.kBodyLarge.copyWith(fontSize: 12, fontWeight: FontWeight.w500)),
        SizedBox(width: context.w(2)),
        Icon(Icons.star, size: 12, color: AppColors.kAmber),
        SizedBox(width: context.w(2)),
        Container(
          width: context.w(80),
          height: context.h(2),
          decoration: BoxDecoration(color: AppColors.kGrey, borderRadius: BorderRadius.circular(3)),
          child: Container(
            decoration: BoxDecoration(color: AppColors.kAmber, borderRadius: BorderRadius.circular(3)),
            width: 80 * (percentage / 100),
          ),
        ),
        const SizedBox(width: 8),
        Text('$percentage%', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    ).padSymmetric(vertical: context.h(2));
  }
}

class _SliverHeaderDelegate extends SliverPersistentHeaderDelegate {
  final double _minExtent;
  final double _maxExtent;
  final Widget child;

  _SliverHeaderDelegate({required double minExtent, required double maxExtent, required this.child})
    : _minExtent = minExtent,
      _maxExtent = maxExtent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(height: _maxExtent, color: Colors.white, child: child);
  }

  @override
  double get minExtent => _minExtent;

  @override
  double get maxExtent => _maxExtent;

  @override
  bool shouldRebuild(covariant _SliverHeaderDelegate oldDelegate) {
    return true;
  }
}
