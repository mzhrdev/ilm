import 'package:lms/features/courses/data/model/course_model.dart';
import 'package:lms/features/courses/data/provider/create_course_provider.dart';
import 'package:uuid/uuid.dart';

extension CourseDraftMapper on CourseDraft {
  CourseModel toCourse({required String instructorId, required String instructorName}) {
    final totalDuration = modules.fold<int>(
      0,
      (sum, module) =>
          sum + module.lessons.fold(0, (lessonSum, lesson) => lessonSum + lesson.durationMinutes),
    );

    return CourseModel(
      id: const Uuid().v4(),
      instructorId: instructorId,

      // --- From Draft ---
      title: title,
      description: description,
      thumbnailUrl: thumbnailPath ?? '',

      modules: modules,

      // --- Provided externally ---
      instructorName: instructorName,

      // --- Default / System Generated ---
      category: 'General', // change later via UI
      price: 0.0, // free by default
      rating: 0.0,
      totalRatings: 0,
      reviews: [],
      skills: [],

      totalDurationMinutes: totalDuration,
    );
  }
}
