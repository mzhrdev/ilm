import 'package:lms/features/courses/data/model/module_model.dart';

class CourseDraft {
  const CourseDraft({
    this.title = '',
    this.description = '',
    this.thumbnailUrl = '',
    this.category = 'General',
    this.price = 0.0,
    this.skills = const [],
    this.modules = const [],
  });

  // -----------------------------
  // Course Basic Information
  // -----------------------------

  final String title;

  final String description;

  final String thumbnailUrl;

  final String category;

  final double price;

  // -----------------------------
  // Additional Course Data
  // -----------------------------

  final List<String> skills;

  final List<ModuleModel> modules;

  // -----------------------------
  // Validation
  // -----------------------------

  bool get isValid {
    return title.trim().isNotEmpty && description.trim().isNotEmpty && modules.isNotEmpty;
  }

  // -----------------------------
  // Copy With
  // -----------------------------

  CourseDraft copyWith({
    String? title,

    String? description,

    String? thumbnailUrl,

    String? category,

    double? price,

    List<String>? skills,

    List<ModuleModel>? modules,
  }) {
    return CourseDraft(
      title: title ?? this.title,

      description: description ?? this.description,

      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,

      category: category ?? this.category,

      price: price ?? this.price,

      // Create new list instances
      // to maintain immutability
      skills: List<String>.from(skills ?? this.skills),

      modules: List<ModuleModel>.from(modules ?? this.modules),
    );
  }
}
