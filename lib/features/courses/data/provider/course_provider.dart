// lib/features/home/data/providers/course_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/auth/data/providers/auth_provider.dart';
import 'package:lms/features/courses/data/dummy_data/dummy_course_list.dart';
import 'package:lms/features/courses/data/model/course_enrollment_model.dart';
import 'package:lms/features/courses/data/provider/continue_watching_provider.dart';
import 'package:lms/features/enrollment/data/provider/enrollment_provider.dart';

import '../model/course_model.dart';

// All courses provider
final coursesProvider = FutureProvider<List<CourseModel>>((ref) async {
  print('[coursesProvider] fetch started');
  // Simulate API delay
  await Future.delayed(const Duration(seconds: 1));
  print('[coursesProvider] fetch completed, count=${mockCourses.length}');
  return mockCourses;
});

final courseDetailProvider = FutureProvider.family<CourseModel, String>((ref, courseId) async {
  final doc = await FirebaseFirestore.instance.collection('courses').doc(courseId).get();

  if (!doc.exists) {
    throw Exception("Course not found");
  }

  return CourseModel.fromFirestore(doc);
});

// Course + Enrollment => User's courses
final courseEnrollmentsProvider = FutureProvider<List<CourseEnrollmentModel>>((ref) async {
  print('[courseEnrollmentsProvider] build started');
  final courses = await ref.watch(coursesProvider.future);
  print('[courseEnrollmentsProvider] courses loaded: ${courses.length}');
  final user = ref.watch(currentUserProvider);
  print('[courseEnrollmentsProvider] userId=${user?.id ?? 'null'}');
  if (user == null) {
    print('[courseEnrollmentsProvider] user is null, returning courses with null enrollment');
    return courses.map((course) => CourseEnrollmentModel(course: course, enrollment: null)).toList();
  }

  final enrollments = await Future.wait(
    courses.map(
      (course) {
        print('[courseEnrollmentsProvider] checking enrollment for courseId=${course.id}');
        return ref.watch(enrollmentLookupProvider((courseId: course.id, userId: user.id)).future);
      },
    ),
  );

  for (var i = 0; i < courses.length; i++) {
    final enrollment = enrollments[i];
    print(
      '[courseEnrollmentsProvider] enrollment result for courseId=${courses[i].id}: '
      '${enrollment == null ? 'null' : 'progress=${enrollment.progress}'}',
    );
  }

  return List.generate(courses.length, (index) {
    return CourseEnrollmentModel(course: courses[index], enrollment: enrollments[index]);
  });
});

// Courses where progress > 0
final myCoursesProvider = Provider<AsyncValue<List<CourseEnrollmentModel>>>((ref) {
  final continueWatchingState = ref.watch(continueWatchingProvider);

  return continueWatchingState.whenData((courses) {
    final filtered = courses.where((courseEnrollment) => courseEnrollment.progress > 0).toList();
    print('[myCoursesProvider] sourceCount=${courses.length}, filteredCount=${filtered.length}');
    return filtered;
  });
});

// Courses where progress >= 1
final completedCoursesProvider = FutureProvider<List<CourseEnrollmentModel>>((ref) async {
  final courses = await ref.watch(courseEnrollmentsProvider.future);
  return courses.where((courseEnrollment) => courseEnrollment.isCompleted).toList();
});
