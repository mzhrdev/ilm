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