// lib/features/home/data/providers/course_provider.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/auth/data/providers/auth_provider.dart';
import 'package:lms/features/courses/data/dummy_data/dummy_course_list.dart';
import 'package:lms/features/courses/data/model/course_enrollment_model.dart';
import 'package:lms/features/enrollment/data/model/enrollment_model.dart';
import 'package:lms/features/enrollment/data/provider/enrollment_provider.dart';

import '../model/course_model.dart';

// All courses provider
final coursesProvider = FutureProvider<List<CourseModel>>((ref) async {
  // Simulate API delay
  await Future.delayed(const Duration(seconds: 1));
  return mockCourses;
});

final courseDetailProvider = FutureProvider.family<CourseModel, String>((ref, courseId) async {
  final doc = await FirebaseFirestore.instance.collection('courses').doc(courseId).get();

  if (!doc.exists) {
    throw Exception("Course not found");
  }

  return CourseModel.fromFirestore(doc);
});

// Course + Whether the user is enrolled in it
final courseEnrollmentsProvider = FutureProvider<List<CourseEnrollmentModel>>((ref) async {
  final courses = await ref.watch(coursesProvider.future);
  final userId = ref.watch(currentUserProvider)?.id;

  final enrollments = userId == null
      ? List<EnrollmentModel?>.filled(courses.length, null)
      : await Future.wait(
          courses.map(
            (course) => ref.watch(enrollmentLookupProvider((courseId: course.id, userId: userId)).future),
          ),
        );

  return List.generate(
    courses.length,
    (index) => CourseEnrollmentModel(course: courses[index], enrollment: enrollments[index]),
  );
});

// Courses where progress > 0
final myCoursesProvider = FutureProvider<List<CourseEnrollmentModel>>((ref) async {
  final courses = await ref.watch(courseEnrollmentsProvider.future);
  return courses.where((courseEnrollment) => courseEnrollment.progress > 0).toList();
});

// Courses where progress >= 1
final completedCoursesProvider = FutureProvider<List<CourseEnrollmentModel>>((ref) async {
  final courses = await ref.watch(courseEnrollmentsProvider.future);
  return courses.where((courseEnrollment) => courseEnrollment.isCompleted).toList();
});
