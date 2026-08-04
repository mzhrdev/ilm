import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/courses/data/dummy_data/dummy_course_list.dart';
import 'package:lms/features/courses/data/model/course_model.dart';
import 'package:lms/features/enrollment/data/model/enrollment_model.dart';

final enrollmentProvider = StateNotifierProvider<EnrollmentNotifier, EnrollmentModel?>((ref) {
  return EnrollmentNotifier();
});

const Map<String, double> _mockEnrollmentProgressByCourseId = {'1': 0.2, '2': 0.65, '3': 1.0};

CourseModel? _findCourseById(String courseId) {
  for (final course in mockCourses) {
    if (course.id == courseId) {
      return course;
    }
  }
  return null;
}

final enrollmentLookupProvider = FutureProvider.family<EnrollmentModel?, ({String courseId, String? userId})>(
  (ref, args) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final userId = args.userId;
    if (userId == null || userId.isEmpty) {
      return null;
    }

    final progress = _mockEnrollmentProgressByCourseId[args.courseId];
    if (progress == null || progress <= 0) {
      return null;
    }

    final course = _findCourseById(args.courseId);
    if (course == null) {
      return null;
    }

    return EnrollmentModel(
      courseId: course.id,
      userId: userId,
      courseName: course.title,
      instructorName: course.instructorName,
      totalLectures: course.totalLessons,
      duration: '${course.totalDurationMinutes ~/ 60} Weeks',
      originalPrice: course.price,
      discountPercentage: 10.0,
      finalPrice: course.price * 0.9,
      couponCode: '10% Off',
      purchaseDate: DateTime.now().subtract(const Duration(days: 7)),
      currentStep: 1,
      hasCertificate: true,
      progress: progress,
    );
  },
);

class EnrollmentNotifier extends StateNotifier<EnrollmentModel?> {
  EnrollmentNotifier() : super(null);

  void initializeFromCourse(CourseModel course, {required String userId}) {
    state = EnrollmentModel(
      courseId: course.id,
      userId: userId,
      courseName: course.title,
      instructorName: course.instructorName,
      totalLectures: course.totalLessons,
      duration: '${course.totalDurationMinutes ~/ 60} Weeks',
      originalPrice: course.price,
      discountPercentage: 10.0, // You can make this dynamic
      finalPrice: course.price * 0.9, // 10% discount
      couponCode: '10% Off',
      purchaseDate: DateTime.now(),
      currentStep: 1,
      hasCertificate: true,
      progress: 0,
    );
  }

  void nextStep() {
    if (state != null && state!.currentStep < 3) {
      state = state!.copyWith(currentStep: state!.currentStep + 1);
    }
  }

  void previousStep() {
    if (state != null && state!.currentStep > 1) {
      state = state!.copyWith(currentStep: state!.currentStep - 1);
    }
  }

  void reset() {
    state = null;
  }
}
