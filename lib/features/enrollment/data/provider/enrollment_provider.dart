import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/courses/data/model/course_model.dart';
import 'package:lms/features/courses/data/provider/continue_watching_provider.dart';
import 'package:lms/features/courses/data/provider/course_provider.dart';
import 'package:lms/features/enrollment/data/model/enrollment_model.dart';

// -----------------------------------------------------------------------------
// ENROLLMENT PROVIDER
// -----------------------------------------------------------------------------

final enrollmentProvider = StateNotifierProvider<EnrollmentNotifier, EnrollmentModel?>((ref) {
  return EnrollmentNotifier(ref);
});

// -----------------------------------------------------------------------------
// ENROLLMENT LOOKUP PROVIDER
// -----------------------------------------------------------------------------

final enrollmentLookupProvider = FutureProvider.family<EnrollmentModel?, ({String courseId, String? userId})>(
  (ref, args) async {
    debugPrint('');
    debugPrint('==================================================');
    debugPrint('[enrollmentLookupProvider] LOOKUP START');
    debugPrint('courseId=${args.courseId}');
    debugPrint('userId=${args.userId ?? 'null'}');
    debugPrint('==================================================');

    final userId = args.userId;

    if (userId == null || userId.isEmpty) {
      debugPrint('[enrollmentLookupProvider] No userId -> returning null');
      return null;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('enrollments')
          .where('courseId', isEqualTo: args.courseId)
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      debugPrint(
        '[enrollmentLookupProvider] '
        'documents found=${snapshot.docs.length}',
      );

      if (snapshot.docs.isEmpty) {
        debugPrint(
          '[enrollmentLookupProvider] '
          'NOT ENROLLED '
          'courseId=${args.courseId}',
        );

        return null;
      }

      final doc = snapshot.docs.first;

      debugPrint(
        '[enrollmentLookupProvider] '
        'ENROLLMENT FOUND '
        'documentId=${doc.id}',
      );

      final enrollment = EnrollmentModel.fromFirestore(doc.data());

      debugPrint(
        '[enrollmentLookupProvider] '
        'courseId=${enrollment.courseId}',
      );

      debugPrint(
        '[enrollmentLookupProvider] '
        'userId=${enrollment.userId}',
      );

      debugPrint(
        '[enrollmentLookupProvider] '
        'progress=${enrollment.progress}',
      );

      debugPrint(
        '[enrollmentLookupProvider] '
        'paidAmount=${enrollment.paidAmount}',
      );

      return enrollment;
    } catch (error, stackTrace) {
      debugPrint(
        '[enrollmentLookupProvider] '
        'ERROR: $error',
      );

      if (kDebugMode) {
        print(stackTrace);
      }

      rethrow;
    }
  },
);

// -----------------------------------------------------------------------------
// ENROLLMENT NOTIFIER
// -----------------------------------------------------------------------------

class EnrollmentNotifier extends StateNotifier<EnrollmentModel?> {
  final Ref ref;

  EnrollmentNotifier(this.ref) : super(null);

  // ---------------------------------------------------------------------------
  // INITIALIZE
  // ---------------------------------------------------------------------------

  void initializeFromCourse(CourseModel course, {required String userId}) {
    debugPrint('');
    debugPrint('==================================================');
    debugPrint('===== INITIALIZE ENROLLMENT =====');
    debugPrint('==================================================');

    debugPrint('Course ID: ${course.id}');
    debugPrint('Course Title: ${course.title}');
    debugPrint('User ID: $userId');

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

    debugPrint('[EnrollmentNotifier] Enrollment state initialized');
    debugPrint('[EnrollmentNotifier] courseId=${state!.courseId}');
    debugPrint('[EnrollmentNotifier] userId=${state!.userId}');
    debugPrint('[EnrollmentNotifier] progress=${state!.progress}');
  }

  // ---------------------------------------------------------------------------
  // SAVE ENROLLMENT
  // ---------------------------------------------------------------------------

  Future<void> saveEnrollment() async {
    final enrollment = state;

    if (enrollment == null) {
      throw StateError('Cannot save enrollment because enrollment state is null.');
    }

    debugPrint('');
    debugPrint('==================================================');
    debugPrint('[EnrollmentNotifier] SAVE ENROLLMENT');
    debugPrint('==================================================');

    debugPrint('courseId=${enrollment.courseId}');
    debugPrint('userId=${enrollment.userId}');
    debugPrint('paidAmount=${enrollment.paidAmount}');
    debugPrint('progress=${enrollment.progress}');

    try {
      final collection = FirebaseFirestore.instance.collection('enrollments');

      // -----------------------------------------------------------------------
      // SAVE TO FIRESTORE
      // -----------------------------------------------------------------------

      final document = await collection.add(enrollment.toJson());

      debugPrint(
        '[EnrollmentNotifier] '
        'ENROLLMENT SAVED SUCCESSFULLY',
      );

      debugPrint(
        '[EnrollmentNotifier] '
        'documentId=${document.id}',
      );

      debugPrint(
        '[EnrollmentNotifier] '
        'courseId=${enrollment.courseId}',
      );

      debugPrint(
        '[EnrollmentNotifier] '
        'userId=${enrollment.userId}',
      );

      // -----------------------------------------------------------------------
      // REFRESH ENROLLMENT LOOKUP
      // -----------------------------------------------------------------------

      debugPrint('');
      debugPrint(
        '[EnrollmentNotifier] '
        'INVALIDATING ENROLLMENT LOOKUP',
      );

      // -----------------------------------------------------------------------
      // REFRESH COURSE + ENROLLMENT DATA
      // -----------------------------------------------------------------------

      debugPrint(
        '[EnrollmentNotifier] '
        'INVALIDATING COURSE ENROLLMENTS',
      );
      ref.invalidate(enrollmentLookupProvider((courseId: enrollment.courseId, userId: enrollment.userId)));
      ref.invalidate(courseEnrollmentsProvider);
      ref.invalidate(continueWatchingProvider);

      debugPrint(
        '[EnrollmentNotifier] '
        'ENROLLMENT DATA REFRESH TRIGGERED',
      );

      debugPrint('==================================================');
      debugPrint('[EnrollmentNotifier] SAVE COMPLETED');
      debugPrint('==================================================');
    } catch (error, stackTrace) {
      debugPrint('');
      debugPrint(
        '[EnrollmentNotifier] '
        'FAILED TO SAVE ENROLLMENT',
      );

      debugPrint('[EnrollmentNotifier] ERROR: $error');
      debugPrint('[EnrollmentNotifier] STACK TRACE:');
      if (kDebugMode) {
        print(stackTrace);
      }

      rethrow;
    }
  }

  // ---------------------------------------------------------------------------
  // NEXT STEP
  // ---------------------------------------------------------------------------

  void nextStep() {
    if (state == null) {
      return;
    }

    if (state!.currentStep < 3) {
      final nextStep = state!.currentStep + 1;

      debugPrint(
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
      debugPrint(
        '[EnrollmentNotifier] '
        'previousStep called but state is null',
      );

      return;
    }

    if (state!.currentStep > 1) {
      final previousStep = state!.currentStep - 1;

      debugPrint(
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
    debugPrint(
      '[EnrollmentNotifier] '
      'Resetting enrollment state',
    );

    state = null;
  }
}
