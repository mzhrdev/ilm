// lib/features/home/data/providers/course_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/courses/data/dummy_data/dummy_course_list.dart';
import '../model/course_model.dart';


// All courses provider
final coursesProvider = FutureProvider<List<CourseModel>>((ref) async {
  // Simulate API delay
  await Future.delayed(const Duration(seconds: 1));
  return mockCourses;
});

// Single course detail provider
final courseDetailProvider =
    FutureProvider.family<CourseModel, String>((ref, courseId) async {
  // Simulate API delay
  await Future.delayed(const Duration(milliseconds: 500));
  
  final course = mockCourses.firstWhere(
    (c) => c.id == courseId,
    orElse: () => throw Exception('Course not found'),
  );
  
  return course;
});

// Continue watching provider (filtered)
final continueWatchingProvider = Provider<List<CourseModel>>((ref) {
  final coursesAsync = ref.watch(coursesProvider);
  
  return coursesAsync.when(
    data: (courses) => courses.where((c) => c.progress > 0).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
});