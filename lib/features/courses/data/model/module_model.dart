
import 'package:lms/features/courses/data/model/lesson_model.dart';

class ModuleModel {
  final String id;
  final String title;
  final List<LessonModel> lessons;

  ModuleModel({required this.id, required this.title, required this.lessons});

  factory ModuleModel.fromJson(Map<String, dynamic> json) {
    return ModuleModel(
      id: json['id'] as String,
      title: json['title'] as String,
      lessons: (json['lessons'] as List).map((l) => LessonModel.fromJson(l)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'lessons': lessons.map((l) => l.toJson()).toList()};
  }
}