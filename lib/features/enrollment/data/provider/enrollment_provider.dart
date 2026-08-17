import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/courses/data/model/course_model.dart';
import 'package:lms/features/enrollment/data/model/enrollment_model.dart';

// -----------------------------------------------------------------------------
// ENROLLMENT PROVIDER
// -----------------------------------------------------------------------------

final enrollmentProvider = StateNotifierProvider<EnrollmentNotifier, EnrollmentModel?>((ref) {
  return EnrollmentNotifier();
});

// -----------------------------------------------------------------------------
// ENROLLMENT LOOKUP PROVIDER
// -----------------------------------------------------------------------------
//
// Finds an existing enrollment for a specific user + course.
//
// Enrollment is determined by the existence of a matching Firestore document.
// Progress is NOT used to determine enrollment.
//
// -----------------------------------------------------------------------------

final enrollmentLookupProvider = FutureProvider.family<EnrollmentModel?, ({String courseId, String? userId})>(
  (ref, args) async {
    print('');
    print('==================================================');
    print('[enrollmentLookupProvider] LOOKUP START');
    print('courseId=${args.courseId}');
    print('userId=${args.userId ?? 'null'}');
    print('==================================================');

    final userId = args.userId;

    if (userId == null || userId.isEmpty) {
      print('[enrollmentLookupProvider] No userId -> returning null');
      return null;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('enrollments')
          .where('courseId', isEqualTo: args.courseId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      print(
        '[enrollmentLookupProvider] '
        'documents found=${snapshot.docs.length}',
      );

      if (snapshot.docs.isEmpty) {
        print(
          '[enrollmentLookupProvider] '
          'NOT ENROLLED '
          'courseId=${args.courseId}',
        );

        return null;
      }

      final doc = snapshot.docs.first;

      print(
        '[enrollmentLookupProvider] '
        'ENROLLMENT FOUND '
        'documentId=${doc.id}',
      );

      final enrollment = EnrollmentModel.fromFirestore(doc.data());

      print(
        '[enrollmentLookupProvider] '
        'courseId=${enrollment.courseId}',
      );

      print(
        '[enrollmentLookupProvider] '
        'userId=${enrollment.userId}',
      );

      print(
        '[enrollmentLookupProvider] '
        'progress=${enrollment.progress}',
      );

      print(
        '[enrollmentLookupProvider] '
        'paidAmount=${enrollment.paidAmount}',
      );

      return enrollment;
    } catch (error, stackTrace) {
      print(
        '[enrollmentLookupProvider] '
        'ERROR: $error',
      );

      print(stackTrace);

      rethrow;
    }
  },
);

// -----------------------------------------------------------------------------
// ENROLLMENT NOTIFIER
// -----------------------------------------------------------------------------

class EnrollmentNotifier extends StateNotifier<EnrollmentModel?> {
  EnrollmentNotifier() : super(null);

  // ---------------------------------------------------------------------------
  // INITIALIZE
  // ---------------------------------------------------------------------------
  //
  // Creates the temporary enrollment state when the user starts enrollment.
  //
  // This does NOT save anything to Firestore yet.
  //
  // ---------------------------------------------------------------------------

  void initializeFromCourse(CourseModel course, {required String userId}) {
    print('');
    print('==================================================');
    print('===== INITIALIZE ENROLLMENT =====');
    print('==================================================');

    print('Course ID: ${course.id}');
    print('Course Title: ${course.title}');
    print('User ID: $userId');

    const discountPercentage = 10.0;

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

    print('[EnrollmentNotifier] Enrollment state initialized');
    print('[EnrollmentNotifier] courseId=${state!.courseId}');
    print('[EnrollmentNotifier] userId=${state!.userId}');
    print('[EnrollmentNotifier] progress=${state!.progress}');
  }

  // ---------------------------------------------------------------------------
  // SAVE ENROLLMENT
  // ---------------------------------------------------------------------------
  //
  // Persists the current enrollment to the existing Firestore collection.
  //
  // The Firestore structure comes directly from EnrollmentModel.toJson().
  //
  // ---------------------------------------------------------------------------

  Future<void> saveEnrollment() async {
    final enrollment = state;

    if (enrollment == null) {
      throw StateError('Cannot save enrollment because enrollment state is null.');
    }

    print('');
    print('==================================================');
    print('[EnrollmentNotifier] SAVE ENROLLMENT');
    print('==================================================');

    print('courseId=${enrollment.courseId}');
    print('userId=${enrollment.userId}');
    print('paidAmount=${enrollment.paidAmount}');
    print('progress=${enrollment.progress}');
   

    try {
      final collection = FirebaseFirestore.instance.collection('enrollments');

      await collection.add(enrollment.toJson());

      print(
        '[EnrollmentNotifier] '
        'ENROLLMENT SAVED SUCCESSFULLY',
      );

      print(
        '[EnrollmentNotifier] '
        'courseId=${enrollment.courseId}',
      );

      print(
        '[EnrollmentNotifier] '
        'userId=${enrollment.userId}',
      );
       print('COURSE SAVED');
    } catch (error, stackTrace) {
      print('');
      print(
        '[EnrollmentNotifier] '
        'FAILED TO SAVE ENROLLMENT',
      );

      print('[EnrollmentNotifier] ERROR: $error');
      print('[EnrollmentNotifier] STACK TRACE:');
      print(stackTrace);

      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // NEXT STEP
  // ---------------------------------------------------------------------------

  void nextStep() {
    if (state == null) {
      // print('[EnrollmentNotifier] nextStep called but state is null');
      return;
    }

    if (state!.currentStep < 3) {
      final nextStep = state!.currentStep + 1;

      print(
        '[EnrollmentNotifier] '
        'Moving from step ${state!.currentStep} to step $nextStep',
      );

      state = state!.copyWith(currentStep: nextStep);
    }
  }

  // ---------------------------------------------------------------------------
  // PREVIOUS STEP
  // ---------------------------------------------------------------------------

  void previousStep() {
    if (state == null) {
      print('[EnrollmentNotifier] previousStep called but state is null');
      return;
    }

    if (state!.currentStep > 1) {
      final previousStep = state!.currentStep - 1;

      print(
        '[EnrollmentNotifier] '
        'Moving from step ${state!.currentStep} to step $previousStep',
      );

      state = state!.copyWith(currentStep: previousStep);
    }
  }

  // ---------------------------------------------------------------------------
  // RESET
  // ---------------------------------------------------------------------------

  void reset() {
    print('[EnrollmentNotifier] Resetting enrollment state');

    state = null;
  }
}
