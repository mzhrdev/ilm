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
