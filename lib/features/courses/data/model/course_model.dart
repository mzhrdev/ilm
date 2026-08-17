import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms/features/courses/data/model/module_model.dart';
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
  final int totalDurationMinutes;
  final List<String> skills;
  final List<ModuleModel> modules;
  final List<ReviewModel> reviews;
  final String instructorId;
  

  CourseModel({
    required this.instructorId,
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
      instructorId: json['instructorId'] as String,
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      instructorName: json['instructorName'] as String,
      thumbnailUrl: json['thumbnailUrl'] as String,
      category: json['category'] as String,
      rating: (json['rating'] as num).toDouble(),
      totalRatings: json['totalRatings'] as int,
      price: (json['price'] as num).toDouble(),

      totalDurationMinutes: json['totalDurationMinutes'] as int,
      skills: List<String>.from(json['skills'] ?? []),
      modules: (modulesJson as List).map((m) => ModuleModel.fromJson(m)).toList(),
      reviews: (reviewsJson as List).map((r) => ReviewModel.fromJson(r)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'instructorId': instructorId,
      'id': id,
      'title': title,
      'description': description,
      'instructorName': instructorName,
      'thumbnailUrl': thumbnailUrl,
      'category': category,
      'rating': rating,
      'totalRatings': totalRatings,
      'price': price,

      'totalDurationMinutes': totalDurationMinutes,
      'skills': skills,
      'modules': modules.map((m) => m.toJson()).toList(),
      'reviews': reviews.map((r) => r.toJson()).toList(),
    };
  }

  factory CourseModel.fromFirestore(DocumentSnapshot doc) {
    final json = doc.data() as Map<String, dynamic>;

    return CourseModel(
      id: doc.id, // <-- Firestore document ID
      instructorId: json['instructorId'],
      title: json['title'],
      description: json['description'],
      instructorName: json['instructorName'],
      thumbnailUrl: json['thumbnailUrl'],
      category: json['category'],
      rating: (json['rating'] ?? 0).toDouble(),
      totalRatings: json['totalRatings'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      totalDurationMinutes: json['totalDurationMinutes'] ?? 0,
      skills: List<String>.from(json['skills'] ?? []),
      modules: (json['modules'] as List<dynamic>? ?? [])
          .map((module) => ModuleModel.fromJson(module as Map<String, dynamic>))
          .toList(),

      reviews: (json['reviews'] as List<dynamic>? ?? [])
          .map((review) => ReviewModel.fromJson(review as Map<String, dynamic>))
          .toList(),
    );
  }
}
