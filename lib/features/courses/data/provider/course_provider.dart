// lib/features/home/data/providers/course_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/auth/data/providers/auth_provider.dart';
import 'package:lms/features/courses/data/dummy_data/dummy_course_list.dart';
import 'package:lms/features/courses/data/model/course_enrollment_model.dart';
import 'package:lms/features/enrollment/data/provider/enrollment_provider.dart';

import '../model/course_model.dart';

// -----------------------------------------------------------------------------
// ALL COURSES
// -----------------------------------------------------------------------------

final coursesProvider = FutureProvider<List<CourseModel>>((ref) async {
  print('[coursesProvider] fetch started');

  // Simulate API delay
  await Future.delayed(const Duration(seconds: 1));

  print('[coursesProvider] fetch completed, count=${mockCourses.length}');

  return mockCourses;
});

// -----------------------------------------------------------------------------
// COURSE DETAIL
// -----------------------------------------------------------------------------

final courseDetailProvider = FutureProvider.family<CourseModel, String>((ref, courseId) async {
  print('[courseDetailProvider] fetching courseId=$courseId');

  final doc = await FirebaseFirestore.instance.collection('courses').doc(courseId).get();

  if (!doc.exists) {
    throw Exception('Course not found');
  }

  return CourseModel.fromFirestore(doc);
});

// -----------------------------------------------------------------------------
// COURSE + ENROLLMENT => USER'S COURSES
// -----------------------------------------------------------------------------

final courseEnrollmentsProvider = FutureProvider<List<CourseEnrollmentModel>>((ref) async {
  print('[courseEnrollmentsProvider] build started');

  final courses = await ref.watch(coursesProvider.future);

  print('[courseEnrollmentsProvider] courses loaded: ${courses.length}');

  final user = ref.watch(currentUserProvider);

  print('[courseEnrollmentsProvider] userId=${user?.id ?? 'null'}');

  // ---------------------------------------------------------------------------
  // No authenticated user
  // ---------------------------------------------------------------------------

  if (user == null || user.id.isEmpty) {
    print('[courseEnrollmentsProvider] no authenticated user');

    return courses.map((course) => CourseEnrollmentModel(course: course, enrollment: null)).toList();
  }

  // ---------------------------------------------------------------------------
  // Look up enrollment for every course
  // ---------------------------------------------------------------------------

  final enrollments = await Future.wait(
    courses.map((course) async {
      print(
        '[courseEnrollmentsProvider] '
        'checking enrollment for courseId=${course.id}',
      );

      try {
        final enrollment = await ref.watch(
          enrollmentLookupProvider((courseId: course.id, userId: user.id)).future,
        );

        print(
          '[courseEnrollmentsProvider] '
          'courseId=${course.id} -> '
          '${enrollment == null ? 'not enrolled' : 'enrolled'}',
        );

        return enrollment;
      } catch (error, stackTrace) {
        print(
          '[courseEnrollmentsProvider] '
          'failed for courseId=${course.id}: $error',
        );

        print(stackTrace);

        // A failed enrollment lookup should not prevent
        // the remaining courses from appearing.
        return null;
      }
    }),
  );

  // ---------------------------------------------------------------------------
  // Combine Course + Enrollment
  // ---------------------------------------------------------------------------

  final result = List.generate(courses.length, (index) {
    final course = courses[index];
    final enrollment = enrollments[index];

    print(
      '[courseEnrollmentsProvider] '
      'courseId=${course.id}, '
      'enrolled=${enrollment != null}, '
      'progress=${enrollment?.progress ?? 0.0}',
    );

    return CourseEnrollmentModel(course: course, enrollment: enrollment);
  });

  print(
    '[courseEnrollmentsProvider] '
    'completed, total=${result.length}',
  );

  return result;
});

// ----------------------------------------------------------------------------
// MY COURSES
// -----------------------------------------------------------------------------
//
// A course belongs to "My Courses" when an enrollment exists.
// Progress is only used to represent learning progress.
//
// -----------------------------------------------------------------------------

final myCoursesProvider = Provider<AsyncValue<List<CourseEnrollmentModel>>>((ref) {
  final courseEnrollmentsState = ref.watch(courseEnrollmentsProvider);

  return courseEnrollmentsState.whenData((courses) {
    final enrolledCourses = courses.where((courseEnrollment) => courseEnrollment.enrollment != null).toList();

    print(
      '[myCoursesProvider] '
      'sourceCount=${courses.length}, '
      'enrolledCount=${enrolledCourses.length}',
    );

    return enrolledCourses;
  });
});

// -----------------------------------------------------------------------------
// COMPLETED COURSES
// -----------------------------------------------------------------------------
//
// Completion is based on progress == 1.0.
// Only enrolled courses can be completed.
//
// -----------------------------------------------------------------------------

final completedCoursesProvider = FutureProvider<List<CourseEnrollmentModel>>((ref) async {
  final courses = await ref.watch(courseEnrollmentsProvider.future);

  return courses
      .where((courseEnrollment) => courseEnrollment.enrollment != null && courseEnrollment.isCompleted)
      .toList();
});
