// lib/features/home/data/providers/course_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/auth/data/providers/current_user_provider.dart';
import 'package:lms/features/courses/data/model/course_enrollment_model.dart';
import 'package:lms/features/enrollment/data/provider/enrollment_provider.dart';

import '../model/course_model.dart';

// -----------------------------------------------------------------------------
// ALL COURSES
// -----------------------------------------------------------------------------
//
// IMPORTANT:
// Courses are loaded from the same Firebase collection used by
// courseDetailProvider.
//
// This ensures that CourseModel.id is always the Firestore document ID.
// -----------------------------------------------------------------------------

final coursesProvider = FutureProvider<List<CourseModel>>((ref) async {
  debugPrint('');
  debugPrint('==================================================');
  debugPrint('[coursesProvider] BUILD STARTED');
  debugPrint('==================================================');

  try {
    final snapshot = await FirebaseFirestore.instance.collection('courses').get();

    debugPrint(
      '[coursesProvider] '
      'Firestore documents loaded=${snapshot.docs.length}',
    );

    final courses = snapshot.docs.map((doc) {
      debugPrint(
        '[coursesProvider] '
        'documentId=${doc.id}',
      );

      final course = CourseModel.fromFirestore(doc);

      debugPrint(
        '[coursesProvider] '
        'courseId=${course.id} | '
        'title=${course.title}',
      );

      return course;
    }).toList();

    debugPrint(
      '[coursesProvider] '
      'FINAL COURSE COUNT=${courses.length}',
    );

    debugPrint('==================================================');
    debugPrint('[coursesProvider] BUILD COMPLETED');
    debugPrint('==================================================');
    debugPrint('');

    return courses;
  } catch (error, stackTrace) {
    debugPrint('');
    debugPrint('==================================================');
    debugPrint('[coursesProvider] ERROR');
    debugPrint('==================================================');
    debugPrint('[coursesProvider] error=$error');
    debugPrint('[coursesProvider] stackTrace=$stackTrace');
    debugPrint('==================================================');
    debugPrint('');

    rethrow;
  }
});

// -----------------------------------------------------------------------------
// COURSE DETAIL
// -----------------------------------------------------------------------------
//
// Fetches one course directly using its Firestore document ID.
// -----------------------------------------------------------------------------

final courseDetailProvider = FutureProvider.family<CourseModel, String>((ref, courseId) async {
  debugPrint('');
  debugPrint('==================================================');
  debugPrint('[courseDetailProvider] FETCH');
  debugPrint('courseId=$courseId');
  debugPrint('==================================================');

  try {
    final doc = await FirebaseFirestore.instance.collection('courses').doc(courseId).get();

    debugPrint(
      '[courseDetailProvider] '
      'document exists=${doc.exists}',
    );

    if (!doc.exists) {
      debugPrint(
        '[courseDetailProvider] '
        'COURSE NOT FOUND: $courseId',
      );

      throw Exception('Course not found');
    }

    final course = CourseModel.fromFirestore(doc);

    debugPrint(
      '[courseDetailProvider] '
      'course loaded: ${course.title}',
    );

    debugPrint(
      '[courseDetailProvider] '
      'course.id=${course.id}',
    );

    return course;
  } catch (error, stackTrace) {
    debugPrint(
      '[courseDetailProvider] '
      'ERROR: $error',
    );

    if (kDebugMode) {
      print(stackTrace);
    }

    rethrow;
  }
});

// -----------------------------------------------------------------------------
// COURSE + ENROLLMENT => USER'S COURSES
// -----------------------------------------------------------------------------
//
// Combines every Firebase CourseModel with the current user's enrollment.
//
// Enrollment is determined by whether an EnrollmentModel exists.
// Progress is NOT used to determine enrollment.
// -----------------------------------------------------------------------------

final courseEnrollmentsProvider = FutureProvider<List<CourseEnrollmentModel>>((ref) async {
  debugPrint('');
  debugPrint('##################################################');
  debugPrint('[courseEnrollmentsProvider] BUILD STARTED');
  debugPrint('##################################################');

  // ---------------------------------------------------------------------------
  // Load courses from Firebase
  // ---------------------------------------------------------------------------

  final courses = await ref.watch(coursesProvider.future);

  debugPrint(
    '[courseEnrollmentsProvider] '
    'courses loaded=${courses.length}',
  );

  for (final course in courses) {
    debugPrint(
      '[courseEnrollmentsProvider] '
      'COURSE -> '
      'id=${course.id} | '
      'title=${course.title}',
    );
  }

  // ---------------------------------------------------------------------------
  // Current user
  // ---------------------------------------------------------------------------

  final user = ref.watch(currentUserProvider);

  debugPrint(
    '[courseEnrollmentsProvider] '
    'currentUser=${user == null ? 'NULL' : 'FOUND'}',
  );

  if (user != null) {
    debugPrint(
      '[courseEnrollmentsProvider] '
      'userId=${user.id}',
    );
  }

  // ---------------------------------------------------------------------------
  // No authenticated user
  // ---------------------------------------------------------------------------

  if (user == null || user.id.isEmpty) {
    debugPrint(
      '[courseEnrollmentsProvider] '
      'NO USER -> returning courses with null enrollment',
    );

    final result = courses.map((course) => CourseEnrollmentModel(course: course, enrollment: null)).toList();

    debugPrint(
      '[courseEnrollmentsProvider] '
      'result count=${result.length}',
    );

    return result;
  }

  // ---------------------------------------------------------------------------
  // Enrollment lookup
  // ---------------------------------------------------------------------------

  debugPrint('');
  debugPrint(
    '[courseEnrollmentsProvider] '
    'STARTING ENROLLMENT LOOKUPS',
  );
  debugPrint('');

  final enrollments = await Future.wait(
    courses.map((course) async {
      debugPrint(
        '[courseEnrollmentsProvider] '
        'LOOKUP START '
        'courseId=${course.id}',
      );

      try {
        final enrollment = await ref.watch(
          enrollmentLookupProvider((courseId: course.id, userId: user.id)).future,
        );

        if (enrollment == null) {
          debugPrint(
            '[courseEnrollmentsProvider] '
            'LOOKUP RESULT '
            'courseId=${course.id} '
            '=> NOT ENROLLED',
          );
        } else {
          debugPrint(
            '[courseEnrollmentsProvider] '
            'LOOKUP RESULT '
            'courseId=${course.id} '
            '=> ENROLLED',
          );

          debugPrint(
            '[courseEnrollmentsProvider] '
            'enrollment.courseId=${enrollment.courseId}',
          );

          debugPrint(
            '[courseEnrollmentsProvider] '
            'enrollment.userId=${enrollment.userId}',
          );

          debugPrint(
            '[courseEnrollmentsProvider] '
            'progress=${enrollment.progress}',
          );

          debugPrint(
            '[courseEnrollmentsProvider] '
            'paidAmount=${enrollment.paidAmount}',
          );

          // Useful sanity check for the exact ID mismatch
          if (enrollment.courseId != course.id) {
            debugPrint(
              '[courseEnrollmentsProvider] '
              'WARNING: COURSE ID MISMATCH '
              'course.id=${course.id} '
              'enrollment.courseId=${enrollment.courseId}',
            );
          }
        }

        return enrollment;
      } catch (error, stackTrace) {
        debugPrint('');
        debugPrint(
          '[courseEnrollmentsProvider] '
          'LOOKUP ERROR '
          'courseId=${course.id}',
        );

        debugPrint(
          '[courseEnrollmentsProvider] '
          'ERROR: $error',
        );

        debugPrint(
          '[courseEnrollmentsProvider] '
          'STACK:',
        );

        if (kDebugMode) {
          print(stackTrace);
        }
        debugPrint('');

        // One failed lookup should not prevent other courses
        // from appearing.
        return null;
      }
    }),
  );

  // ---------------------------------------------------------------------------
  // Enrollment lookup summary
  // ---------------------------------------------------------------------------

  debugPrint('');
  debugPrint(
    '[courseEnrollmentsProvider] '
    'ENROLLMENT LOOKUPS COMPLETED',
  );

  for (var i = 0; i < courses.length; i++) {
    final course = courses[i];
    final enrollment = enrollments[i];

    debugPrint(
      '[courseEnrollmentsProvider] '
      '${course.title} '
      '(courseId=${course.id}) '
      '=> '
      '${enrollment == null ? 'NOT ENROLLED' : 'ENROLLED'}',
    );
  }

  // ---------------------------------------------------------------------------
  // Combine Course + Enrollment
  // ---------------------------------------------------------------------------

  debugPrint('');
  debugPrint(
    '[courseEnrollmentsProvider] '
    'BUILDING CourseEnrollmentModel LIST',
  );

  final result = List.generate(courses.length, (index) {
    final course = courses[index];
    final enrollment = enrollments[index];

    debugPrint(
      '[courseEnrollmentsProvider] '
      'COMBINING '
      'courseId=${course.id} '
      '| course=${course.title} '
      '| enrolled=${enrollment != null} '
      '| progress=${enrollment?.progress ?? 0.0}',
    );

    return CourseEnrollmentModel(course: course, enrollment: enrollment);
  });

  // ---------------------------------------------------------------------------
  // Final summary
  // ---------------------------------------------------------------------------

  final enrolledCount = result.where((course) {
    return course.enrollment != null;
  }).length;

  debugPrint('');
  debugPrint(
    '[courseEnrollmentsProvider] '
    'FINAL RESULT COUNT=${result.length}',
  );

  debugPrint(
    '[courseEnrollmentsProvider] '
    'FINAL ENROLLED COUNT=$enrolledCount',
  );

  debugPrint('##################################################');
  debugPrint('[courseEnrollmentsProvider] BUILD COMPLETED');
  debugPrint('##################################################');
  debugPrint('');

  return result;
});

// -----------------------------------------------------------------------------
// MY COURSES
// -----------------------------------------------------------------------------
//
// A course belongs to My Courses when an EnrollmentModel exists.
//
// IMPORTANT:
// progress == 0 is still an enrolled course.
// Therefore progress is NOT used as the enrollment condition.
// -----------------------------------------------------------------------------

final myCoursesProvider = Provider<AsyncValue<List<CourseEnrollmentModel>>>((ref) {
  debugPrint('');
  debugPrint('--------------------------------------------------');
  debugPrint('[myCoursesProvider] BUILD');
  debugPrint('--------------------------------------------------');

  final courseEnrollmentsState = ref.watch(courseEnrollmentsProvider);

  debugPrint(
    '[myCoursesProvider] '
    'state=${courseEnrollmentsState.runtimeType}',
  );

  return courseEnrollmentsState.whenData((courses) {
    debugPrint(
      '[myCoursesProvider] '
      'received=${courses.length} courses',
    );

    for (final course in courses) {
      debugPrint(
        '[myCoursesProvider] '
        'course=${course.title} '
        '| id=${course.id} '
        '| enrolled=${course.enrollment != null} '
        '| progress=${course.progress}',
      );
    }

    final enrolledCourses = courses.where((courseEnrollment) => courseEnrollment.enrollment != null).toList();

    debugPrint(
      '[myCoursesProvider] '
      'ENROLLED COURSES=${enrolledCourses.length}',
    );

    for (final course in enrolledCourses) {
      debugPrint(
        '[myCoursesProvider] '
        'MY COURSE -> '
        '${course.title} '
        '| id=${course.id} '
        '| progress=${course.progress}',
      );
    }

    return enrolledCourses;
  });
});

// -----------------------------------------------------------------------------
// COMPLETED COURSES
// -----------------------------------------------------------------------------
//
// A course is completed only when:
// 1. The user is enrolled.
// 2. CourseEnrollmentModel reports isCompleted.
// -----------------------------------------------------------------------------

final completedCoursesProvider = FutureProvider<List<CourseEnrollmentModel>>((ref) async {
  debugPrint('');
  debugPrint('--------------------------------------------------');
  debugPrint('[completedCoursesProvider] BUILD');
  debugPrint('--------------------------------------------------');

  final courses = await ref.watch(courseEnrollmentsProvider.future);

  debugPrint(
    '[completedCoursesProvider] '
    'received=${courses.length} courses',
  );

  final completedCourses = courses
      .where((courseEnrollment) => courseEnrollment.enrollment != null && courseEnrollment.isCompleted)
      .toList();

  debugPrint(
    '[completedCoursesProvider] '
    'completedCount=${completedCourses.length}',
  );

  for (final course in completedCourses) {
    debugPrint(
      '[completedCoursesProvider] '
      'COMPLETED -> '
      '${course.title} '
      '| id=${course.id} '
      '| progress=${course.progress}',
    );
  }

  return completedCourses;
});
