import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/courses/data/model/lesson_model.dart';
import 'package:lms/features/courses/data/model/module_model.dart';

class CourseDraft {
  const CourseDraft({this.title = '', this.description = '', this.thumbnailPath, this.modules = const []});

  final String title;
  final String description;
  final String? thumbnailPath;
  final List<ModuleModel> modules;

  static const Object _unset = Object();

  CourseDraft copyWith({
    String? title,
    String? description,
    Object? thumbnailPath = _unset,
    List<ModuleModel>? modules,
  }) {
    return CourseDraft(
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailPath: identical(thumbnailPath, _unset) ? this.thumbnailPath : thumbnailPath as String?,
      modules: modules ?? this.modules,
    );
  }
}

final createCourseProvider = StateNotifierProvider<CreateCourseNotifier, CourseDraft>((ref) {
  return CreateCourseNotifier();
});

class CreateCourseNotifier extends StateNotifier<CourseDraft> {
  CreateCourseNotifier() : super(const CourseDraft());

  // ---------------------------------------------------------------------
  // Basic fields
  // ---------------------------------------------------------------------

  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setThumbnail(String? path) {
    state = state.copyWith(thumbnailPath: path);
  }

  void clearThumbnail() {
    state = state.copyWith(thumbnailPath: null);
  }

  // ---------------------------------------------------------------------
  // Internal helper — find a module by id, transform it, put it back.
  // Every module-scoped mutation (lessons included) goes through this so
  // there's exactly one place that does the "find + replace" dance.
  // ---------------------------------------------------------------------

  void _updateModule(String moduleId, ModuleModel Function(ModuleModel module) transform) {
    final index = state.modules.indexWhere((m) => m.id == moduleId);
    assert(index != -1, '_updateModule: no module found with id $moduleId');
    if (index == -1) return; // no-op in release builds if id is stale/wrong

    final updatedModules = [...state.modules];
    updatedModules[index] = transform(updatedModules[index]);
    state = state.copyWith(modules: updatedModules);
  }

  // ---------------------------------------------------------------------
  // Modules
  // ---------------------------------------------------------------------

  void addModule(ModuleModel module) {
    assert(
      state.modules.every((m) => m.id != module.id),
      'addModule: a module with id ${module.id} already exists',
    );
    state = state.copyWith(modules: [...state.modules, module]);
  }

  void removeModule(String moduleId) {
    state = state.copyWith(modules: state.modules.where((m) => m.id != moduleId).toList());
  }

  void updateModule(String moduleId, {String? title}) {
    _updateModule(moduleId, (module) => module.copyWith(title: title));
  }

  

  // ---------------------------------------------------------------------
  // Lessons (inside a module)
  // ---------------------------------------------------------------------

  void addLesson(String moduleId, LessonModel lesson) {
    _updateModule(moduleId, (module) {
      assert(
        module.lessons.every((l) => l.id != lesson.id),
        'addLesson: a lesson with id ${lesson.id} already exists in module $moduleId',
      );
      return module.copyWith(lessons: [...module.lessons, lesson]);
    });
  }

  void removeLesson(String moduleId, String lessonId) {
    _updateModule(
      moduleId,
      (module) => module.copyWith(lessons: module.lessons.where((l) => l.id != lessonId).toList()),
    );
  }

  void updateLesson(String moduleId, String lessonId, LessonModel updatedLesson) {
    _updateModule(
      moduleId,
      (module) =>
          module.copyWith(lessons: module.lessons.map((l) => l.id == lessonId ? updatedLesson : l).toList()),
    );
  }


  // ---------------------------------------------------------------------
  // Reset
  // ---------------------------------------------------------------------

  void clear() {
    state = const CourseDraft();
  }
}
