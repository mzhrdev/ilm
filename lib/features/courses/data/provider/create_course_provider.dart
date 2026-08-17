import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/courses/data/model/course_draft_model.dart';
import 'package:lms/features/courses/data/model/lesson_model.dart';
import 'package:lms/features/courses/data/model/module_model.dart';

final createCourseProvider = StateNotifierProvider<CreateCourseNotifier, CourseDraft>((ref) {
  return CreateCourseNotifier();
});

class CreateCourseNotifier extends StateNotifier<CourseDraft> {
  CreateCourseNotifier() : super(const CourseDraft());

  // ---------------------------------------------------------
  // Basic Course Information
  // ---------------------------------------------------------

  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setThumbnailUrl(String url) {
    state = state.copyWith(thumbnailUrl: url);
  }

  void setCategory(String category) {
    state = state.copyWith(category: category);
  }

  void setPrice(double price) {
    state = state.copyWith(price: price);
  }

  void setSkills(List<String> skills) {
    state = state.copyWith(skills: skills);
  }

  // ---------------------------------------------------------
  // Internal Module Update Helper
  // ---------------------------------------------------------

  void _updateModule(String moduleId, ModuleModel Function(ModuleModel module) transform) {
    final index = state.modules.indexWhere((module) => module.id == moduleId);

    if (index == -1) {
      return;
    }

    final updatedModules = [...state.modules];

    updatedModules[index] = transform(updatedModules[index]);

    state = state.copyWith(modules: updatedModules);
  }

  // ---------------------------------------------------------
  // Modules
  // ---------------------------------------------------------

  void addModule(ModuleModel module) {
    final exists = state.modules.any((item) => item.id == module.id);

    if (exists) {
      return;
    }

    state = state.copyWith(modules: [...state.modules, module]);
  }

  void removeModule(String moduleId) {
    state = state.copyWith(modules: state.modules.where((module) => module.id != moduleId).toList());
  }

  void updateModule(String moduleId, {String? title}) {
    _updateModule(moduleId, (module) {
      return module.copyWith(title: title);
    });
  }

  // ---------------------------------------------------------
  // Lessons
  // ---------------------------------------------------------

  void addLesson(String moduleId, LessonModel lesson) {
    _updateModule(moduleId, (module) {
      final exists = module.lessons.any((item) => item.id == lesson.id);

      if (exists) {
        return module;
      }

      return module.copyWith(lessons: [...module.lessons, lesson]);
    });
  }

  void removeLesson(String moduleId, String lessonId) {
    _updateModule(moduleId, (module) {
      return module.copyWith(lessons: module.lessons.where((lesson) => lesson.id != lessonId).toList());
    });
  }

  void updateLesson(String moduleId, String lessonId, LessonModel updatedLesson) {
    _updateModule(moduleId, (module) {
      return module.copyWith(
        lessons: module.lessons.map((lesson) {
          return lesson.id == lessonId ? updatedLesson : lesson;
        }).toList(),
      );
    });
  }

  // ---------------------------------------------------------
  // Reset
  // ---------------------------------------------------------

  void clear() {
    state = const CourseDraft();
  }
}
