import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/courses/data/model/course_model.dart';
import 'package:lms/features/enrollment/data/model/enrollment_model.dart';

// enrollment provider
final enrollmentProvider = StateNotifierProvider<EnrollmentNotifier, EnrollmentModel?>((ref) {
  return EnrollmentNotifier();
});

// enrollment lookup provider
final enrollmentLookupProvider = FutureProvider.family<EnrollmentModel?, ({String courseId, String? userId})>(
  (ref, args) async {
    final userId = args.userId;

    if (userId == null || userId.isEmpty) {
      return null;
    }

    final snapshot = await FirebaseFirestore.instance
        .collection('enrollments')
        .where('courseId', isEqualTo: args.courseId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return EnrollmentModel.fromFirestore(snapshot.docs.first.data());
  },
);

// enrollment notifier class
class EnrollmentNotifier extends StateNotifier<EnrollmentModel?> {
  EnrollmentNotifier() : super(null);

  // Initialize enrollment from the actual Firebase CourseModel.
  void initializeFromCourse(CourseModel course, {required String userId}) {
    final discountPercentage = 10.0;
    final paidAmount = course.price - (course.price * discountPercentage / 100);

    state = EnrollmentModel(
      courseId: course.id,
      userId: userId,
      originalPrice: course.price,
      discountPercentage: discountPercentage,
      paidAmount: paidAmount,
      couponCode: '10% Off',
      purchaseDate: DateTime.now(),
      currentStep: 1,
      hasCertificate: true,
      progress: 0.0,
    );
  }

  void nextStep() {
    if (state == null) return;

    if (state!.currentStep < 3) {
      state = state!.copyWith(currentStep: state!.currentStep + 1);
    }
  }

  void previousStep() {
    if (state == null) return;

    if (state!.currentStep > 1) {
      state = state!.copyWith(currentStep: state!.currentStep - 1);
    }
  }

  void reset() {
    state = null;
  }
}
