import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/courses/data/model/course_model.dart';
import 'package:lms/features/courses/data/services/course_service.dart';

final continueWatchingProvider = StreamProvider<List<CourseModel>>((ref) {
  return CourseService().getCoursesWithEnrollment();
});
