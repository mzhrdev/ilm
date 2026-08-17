// lib/features/home/data/providers/course_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Edvance/features/auth/data/providers/auth_provider.dart';
import 'package:Edvance/features/courses/data/model/course_enrollment_model.dart';
import 'package:Edvance/features/enrollment/data/provider/enrollment_provider.dart';

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
  print('');
  print('==================================================');
  print('[coursesProvider] BUILD STARTED');
  print('==================================================');

  try {
    final snapshot = await FirebaseFirestore.instance.collection('courses').get();

    print(
      '[coursesProvider] '
      'Firestore documents loaded=${snapshot.docs.length}',
    );

    final courses = snapshot.docs.map((doc) {
      print(
        '[coursesProvider] '
        'documentId=${doc.id}',
      );

      final course = CourseModel.fromFirestore(doc);

      print(
        '[coursesProvider] '
        'courseId=${course.id} | '
        'title=${course.title}',
      );

      return course;
    }).toList();

    print(
      '[coursesProvider] '
      'FINAL COURSE COUNT=${courses.length}',
    );

    print('==================================================');
    print('[coursesProvider] BUILD COMPLETED');
    print('==================================================');
    print('');

    return courses;
  } catch (error, stackTrace) {
    print('');
    print('==================================================');
    print('[coursesProvider] ERROR');
    print('==================================================');
    print('[coursesProvider] error=$error');
    print('[coursesProvider] stackTrace=$stackTrace');
    print('==================================================');
    print('');

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
  print('');
  print('==================================================');
  print('[courseDetailProvider] FETCH');
  print('courseId=$courseId');
  print('==================================================');

  try {
    final doc = await FirebaseFirestore.instance.collection('courses').doc(courseId).get();

    print(
      '[courseDetailProvider] '
      'document exists=${doc.exists}',
    );

    if (!doc.exists) {
      print(
        '[courseDetailProvider] '
        'COURSE NOT FOUND: $courseId',
      );

      throw Exception('Course not found');
    }

    final course = CourseModel.fromFirestore(doc);

    print(
      '[courseDetailProvider] '
      'course loaded: ${course.title}',
    );

    print(
      '[courseDetailProvider] '
      'course.id=${course.id}',
    );

    return course;
  } catch (error, stackTrace) {
    print(
      '[courseDetailProvider] '
      'ERROR: $error',
    );

    print(stackTrace);

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
  print('');
  print('##################################################');
  print('[courseEnrollmentsProvider] BUILD STARTED');
  print('##################################################');

  // ---------------------------------------------------------------------------
  // Load courses from Firebase
  // ---------------------------------------------------------------------------

  final courses = await ref.watch(coursesProvider.future);

  print(
    '[courseEnrollmentsProvider] '
    'courses loaded=${courses.length}',
  );

  for (final course in courses) {
    print(
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

  print(
    '[courseEnrollmentsProvider] '
    'currentUser=${user == null ? 'NULL' : 'FOUND'}',
  );

  if (user != null) {
    print(
      '[courseEnrollmentsProvider] '
      'userId=${user.id}',
    );
  }

  // ---------------------------------------------------------------------------
  // No authenticated user
  // ---------------------------------------------------------------------------

  if (user == null || user.id.isEmpty) {
    print(
      '[courseEnrollmentsProvider] '
      'NO USER -> returning courses with null enrollment',
    );

    final result = courses.map((course) => CourseEnrollmentModel(course: course, enrollment: null)).toList();

    print(
      '[courseEnrollmentsProvider] '
      'result count=${result.length}',
    );

    return result;
  }

  // ---------------------------------------------------------------------------
  // Enrollment lookup
  // ---------------------------------------------------------------------------

  print('');
  print(
    '[courseEnrollmentsProvider] '
    'STARTING ENROLLMENT LOOKUPS',
  );
  print('');

  final enrollments = await Future.wait(
    courses.map((course) async {
      print(
        '[courseEnrollmentsProvider] '
        'LOOKUP START '
        'courseId=${course.id}',
      );

      try {
        final enrollment = await ref.watch(
          enrollmentLookupProvider((courseId: course.id, userId: user.id)).future,
        );

        if (enrollment == null) {
          print(
            '[courseEnrollmentsProvider] '
            'LOOKUP RESULT '
            'courseId=${course.id} '
            '=> NOT ENROLLED',
          );
        } else {
          print(
            '[courseEnrollmentsProvider] '
            'LOOKUP RESULT '
            'courseId=${course.id} '
            '=> ENROLLED',
          );

          print(
            '[courseEnrollmentsProvider] '
            'enrollment.courseId=${enrollment.courseId}',
          );

          print(
            '[courseEnrollmentsProvider] '
            'enrollment.userId=${enrollment.userId}',
          );

          print(
            '[courseEnrollmentsProvider] '
            'progress=${enrollment.progress}',
          );

          print(
            '[courseEnrollmentsProvider] '
            'paidAmount=${enrollment.paidAmount}',
          );

          // Useful sanity check for the exact ID mismatch
          if (enrollment.courseId != course.id) {
            print(
              '[courseEnrollmentsProvider] '
              'WARNING: COURSE ID MISMATCH '
              'course.id=${course.id} '
              'enrollment.courseId=${enrollment.courseId}',
            );
          }
        }

        return enrollment;
      } catch (error, stackTrace) {
        print('');
        print(
          '[courseEnrollmentsProvider] '
          'LOOKUP ERROR '
          'courseId=${course.id}',
        );

        print(
          '[courseEnrollmentsProvider] '
          'ERROR: $error',
        );

        print(
          '[courseEnrollmentsProvider] '
          'STACK:',
        );

        print(stackTrace);
        print('');

        // One failed lookup should not prevent other courses
        // from appearing.
        return null;
      }
    }),
  );

  // ---------------------------------------------------------------------------
  // Enrollment lookup summary
  // ---------------------------------------------------------------------------

  print('');
  print(
    '[courseEnrollmentsProvider] '
    'ENROLLMENT LOOKUPS COMPLETED',
  );

  for (var i = 0; i < courses.length; i++) {
    final course = courses[i];
    final enrollment = enrollments[i];

    print(
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

  print('');
  print(
    '[courseEnrollmentsProvider] '
    'BUILDING CourseEnrollmentModel LIST',
  );

  final result = List.generate(courses.length, (index) {
    final course = courses[index];
    final enrollment = enrollments[index];

    print(
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

  print('');
  print(
    '[courseEnrollmentsProvider] '
    'FINAL RESULT COUNT=${result.length}',
  );

  print(
    '[courseEnrollmentsProvider] '
    'FINAL ENROLLED COUNT=$enrolledCount',
  );

  print('##################################################');
  print('[courseEnrollmentsProvider] BUILD COMPLETED');
  print('##################################################');
  print('');

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
  print('');
  print('--------------------------------------------------');
  print('[myCoursesProvider] BUILD');
  print('--------------------------------------------------');

  final courseEnrollmentsState = ref.watch(courseEnrollmentsProvider);

  print(
    '[myCoursesProvider] '
    'state=${courseEnrollmentsState.runtimeType}',
  );

  return courseEnrollmentsState.whenData((courses) {
    print(
      '[myCoursesProvider] '
      'received=${courses.length} courses',
    );

    for (final course in courses) {
      print(
        '[myCoursesProvider] '
        'course=${course.title} '
        '| id=${course.id} '
        '| enrolled=${course.enrollment != null} '
        '| progress=${course.progress}',
      );
    }

    final enrolledCourses = courses.where((courseEnrollment) => courseEnrollment.enrollment != null).toList();

    print(
      '[myCoursesProvider] '
      'ENROLLED COURSES=${enrolledCourses.length}',
    );

    for (final course in enrolledCourses) {
      print(
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
  print('');
  print('--------------------------------------------------');
  print('[completedCoursesProvider] BUILD');
  print('--------------------------------------------------');

  final courses = await ref.watch(courseEnrollmentsProvider.future);

  print(
    '[completedCoursesProvider] '
    'received=${courses.length} courses',
  );

  final completedCourses = courses
      .where((courseEnrollment) => courseEnrollment.enrollment != null && courseEnrollment.isCompleted)
      .toList();

  print(
    '[completedCoursesProvider] '
    'completedCount=${completedCourses.length}',
  );

  for (final course in completedCourses) {
    print(
      '[completedCoursesProvider] '
      'COMPLETED -> '
      '${course.title} '
      '| id=${course.id} '
      '| progress=${course.progress}',
    );
  }

  return completedCourses;
});
