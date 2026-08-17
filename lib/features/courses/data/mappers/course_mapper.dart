import 'package:Edvance/features/courses/data/model/course_draft_model.dart';
import 'package:Edvance/features/courses/data/model/course_model.dart';

extension CourseDraftMapper on CourseDraft {
  CourseModel toCourse({required String id, required String instructorId, required String instructorName}) {
    final totalDurationMinutes = modules.fold<int>(0, (total, module) {
      return total +
          module.lessons.fold<int>(0, (lessonTotal, lesson) {
            return lessonTotal + lesson.durationMinutes;
          });
    });

    return CourseModel(
      // -----------------------------
      // Identity
      // -----------------------------
      id: id,

      instructorId: instructorId,

      instructorName: instructorName,

      // -----------------------------
      // Course Draft Data
      // -----------------------------
      title: title,

      description: description,

      thumbnailUrl: thumbnailUrl,

      category: category,

      price: price,

      skills: skills,

      modules: modules,

      // -----------------------------
      // Generated Defaults
      // -----------------------------
      rating: 0.0,

      totalRatings: 0,

      reviews: [],

      // -----------------------------
      // Calculated Data
      // -----------------------------
      totalDurationMinutes: totalDurationMinutes,
    );
  }
}
