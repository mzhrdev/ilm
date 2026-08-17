import 'package:Edvance/features/courses/data/model/course_model.dart';
import 'package:Edvance/features/enrollment/data/model/enrollment_model.dart';

class CourseEnrollmentModel {
  final CourseModel course;
  final EnrollmentModel? enrollment;

  const CourseEnrollmentModel({required this.course, required this.enrollment});

  double get progress => enrollment?.progress ?? 0;

  String get id => course.id;

  String get title => course.title;

  String get instructorName => course.instructorName;

  String get thumbnailUrl => course.thumbnailUrl;

  double get rating => course.rating;

  bool get hasProgress => progress > 0;

  bool get isCompleted => progress >= 1;
}
