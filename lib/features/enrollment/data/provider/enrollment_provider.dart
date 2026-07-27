import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/enrollment/data/model/enrollment_model.dart';
import 'package:lms/features/courses/data/model/course_model.dart';


final enrollmentProvider = StateNotifierProvider<EnrollmentNotifier, EnrollmentModel?>((ref) {
  return EnrollmentNotifier();
});

class EnrollmentNotifier extends StateNotifier<EnrollmentModel?> {
  EnrollmentNotifier() : super(null);

  void initializeFromCourse(CourseModel course) {
    state = EnrollmentModel(
      courseId: course.id,
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
