// lib/features/home/data/model/course_model.dart

import 'package:lms/features/home/data/model/review_model.dart';

class CourseModel {
  final String id;
  final String title;
  final String description;
  final String instructorName;
  final String thumbnailUrl;
  final String category;
  final double rating;
  final int totalRatings;
  final double price;
  final double progress; // 0.0 to 1.0
  final int totalDurationMinutes;
  final List<String> skills;
  final List<ModuleModel> modules;
  final List<ReviewModel> reviews;

  CourseModel({
    required this.reviews,
    required this.id,
    required this.title,
    required this.description,
    required this.instructorName,
    required this.thumbnailUrl,
    required this.category,
    required this.rating,
    required this.totalRatings,
    required this.price,
    required this.progress,
    required this.totalDurationMinutes,
    required this.skills,
    required this.modules,
  });

  int get totalLessons {
    return modules.fold(0, (sum, module) => sum + module.lessons.length);
  }

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    final reviewsJson = json['reviews'] ?? [];
    final modulesJson = json['modules'] ?? [];
    return CourseModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      instructorName: json['instructorName'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
      totalRatings: json['totalRatings'] as int,
      price: (json['price'] as num).toDouble(),
      progress: (json['progress'] as num).toDouble(),
      totalDurationMinutes: json['totalDurationMinutes'] as int,
      skills: List<String>.from(json['skills'] ?? []),
      modules: (modulesJson as List).map((m) => ModuleModel.fromJson(m)).toList(),
      reviews: (reviewsJson as List).map((r) => ReviewModel.fromJson(r)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'instructorName': instructorName,
      'thumbnailUrl': thumbnailUrl,
      'category': category,
      'rating': rating,
      'totalRatings': totalRatings,
      'price': price,
      'progress': progress,
      'totalDurationMinutes': totalDurationMinutes,
      'skills': skills,
      'modules': modules.map((m) => m.toJson()).toList(),
      'reviews': reviews.map((r) => r.toJson()).toList(),
    };
  }
}

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

class LessonModel {
  final String id;
  final String title;
  final String type; // 'video', 'text', 'quiz'
  final int durationMinutes;
  final bool isFree;

  LessonModel({
    required this.id,
    required this.title,
    required this.type,
    required this.durationMinutes,
    required this.isFree,
  });

  factory LessonModel.fromJson(Map<String, dynamic> json) {
    return LessonModel(
      id: json['id'] as String,
      title: json['title'] as String,
      type: json['type'] as String,
      durationMinutes: json['durationMinutes'] as int,
      isFree: json['isFree'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'type': type, 'durationMinutes': durationMinutes, 'isFree': isFree};
  }
}
