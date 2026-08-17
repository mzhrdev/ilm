import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/courses/data/model/course_enrollment_model.dart';
import 'package:lms/features/courses/data/services/course_service.dart';

final continueWatchingProvider = StreamProvider<List<CourseEnrollmentModel>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) {
    return Stream.value([]);
  }
  return CourseService().getCoursesWithEnrollment(user.uid);
});
