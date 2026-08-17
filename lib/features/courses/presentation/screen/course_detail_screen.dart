// lib/features/course_detail/presentation/screens/course_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/auth/data/providers/auth_provider.dart';
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

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

    return Scaffold(
      backgroundColor: Colors.white,

      body: courseAsync.when(
        data: (course) => _buildCourseDetailContent(course),

        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),

              const SizedBox(height: 8),

              Text('Error: $error'),

              const SizedBox(height: 16),

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
    );
  }

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
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),

      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,

          child: ElevatedButton(
            onPressed: isCheckingEnrollment
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

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,

              disabledBackgroundColor: isEnrolled ? Colors.grey[300] : Colors.grey[400],

              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),

            child: Text(
              buttonText,

              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,

                color: isEnrolled ? Colors.black87 : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseDetailContent(CourseModel course) {
    return CustomScrollView(
      slivers: [
        // Video Thumbnail with Back Button
        SliverToBoxAdapter(
          child: Stack(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                color: Colors.grey[300],
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(Icons.play_circle_outline, size: 80, color: Colors.white),
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: const Icon(Icons.play_arrow, color: Colors.black, size: 40),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new, size: 20),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.bookmark_border, size: 20),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

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
            height: MediaQuery.of(context).size.height - 450,
            child: TabBarView(
              controller: _tabController,
              children: [_buildOverviewTab(course), _buildLessonsTab(course), _buildReviewsTab(course)],
            ),
          ),
        ),
      ],
    );
  }

  // ✅ FIX: Wrapped in SingleChildScrollView to prevent overflow
  Widget _buildOverviewTab(CourseModel course) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title and Price
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(course.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'By ${course.instructorName}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < course.rating.floor() ? Icons.star : Icons.star_border,
                            color: Colors.amber[700],
                            size: 20,
                          );
                        }),
                        const SizedBox(width: 8),
                        Text('${course.rating}', style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              Text('${course.price}\$', style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            ],
          ),

          const SizedBox(height: 24),

          // Description
          const Text('Description', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Text(course.description, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.5)),

          const SizedBox(height: 24),

          // Course Info Card
          CourseInfoCard(
            lectures: course.totalLessons,
            duration: '${course.totalDurationMinutes ~/ 60} Weeks',
            hasCertificate: true,
            discount: 10,
          ),

          const SizedBox(height: 24),

          // Skills
          const Text('Skills', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: course.skills.map((skill) => SkillChip(label: skill)).toList(),
          ),

          // Extra bottom padding to ensure it clears the bottom nav when scrolling
          const SizedBox(height: 20),
        ],
      ),
    );
  }
  // Replace the _buildLessonsTab method with this:

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
            _buildChapterCard(
              chapterNumber: i + 1,
              chapterTitle: course.modules[i].title,
              lessons: course.modules[i].lessons,
              isExpanded: i == 0, // Expand first chapter by default
            ),
          const SizedBox(height: 80), // Space for bottom navigation
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
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chapter Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Chapter $chapterNumber: $chapterTitle',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
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
            child: Text(lesson.title, style: const TextStyle(fontSize: 14, color: Colors.black87)),
          ),
          // Lock icon if not free
          if (!lesson.isFree) const Icon(Icons.lock_outline, size: 18, color: Colors.grey),
        ],
      ),
    );
  }

  // In lib/features/course_detail/presentation/screens/course_detail_screen.dart

  // Replace the _buildReviewsTab method with this:

  Widget _buildReviewsTab(CourseModel course) {
    if (course.reviews.isEmpty) {
      return const Center(
        child: Text('No reviews yet', style: TextStyle(color: Colors.grey)),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Optional: Show average rating summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(12)),
            child: Row(
              children: [
                // Average Rating
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      course.rating.toString(),
                      style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) {
                          return Icon(
                            index < course.rating.floor() ? Icons.star : Icons.star_border,
                            color: Colors.amber[700],
                            size: 20,
                          );
                        }),
                      ],
                    ),
                    Text(
                      '${course.totalRatings} reviews',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
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
          const SizedBox(height: 20),
          // Reviews List
          const Text('All Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          ...course.reviews.map((review) => ReviewCard(review: review)),
          const SizedBox(height: 80), // Space for bottom navigation
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, int percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text('$stars', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          const SizedBox(width: 4),
          const Icon(Icons.star, size: 12, color: Colors.amber),
          const SizedBox(width: 8),
          Container(
            width: 80,
            height: 6,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(3)),
            child: Container(
              decoration: BoxDecoration(color: Colors.amber[700], borderRadius: BorderRadius.circular(3)),
              width: 80 * (percentage / 100),
            ),
          ),
          const SizedBox(width: 8),
          Text('$percentage%', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
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
