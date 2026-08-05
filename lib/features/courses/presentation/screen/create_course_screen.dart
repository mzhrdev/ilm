import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/data/services/firebase_firestore_services.dart';
import 'package:lms/core/presentation/widgets/custom_elevated_button.dart';
import 'package:lms/core/presentation/widgets/snackbar.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/courses/data/mappers/course_mapper.dart';
import 'package:lms/features/courses/data/model/lesson_model.dart';
import 'package:lms/features/courses/data/model/module_model.dart';
import 'package:lms/features/courses/data/provider/create_course_provider.dart';
import 'package:uuid/uuid.dart';

class CreateCourseScreen extends ConsumerWidget {
  const CreateCourseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final draft = ref.watch(createCourseProvider);
    final notifier = ref.read(createCourseProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Create Course')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ---------------- TITLE ----------------
            TextField(
              decoration: const InputDecoration(labelText: 'Course Title'),
              onChanged: notifier.setTitle,
            ),

            const SizedBox(height: 12),

            // ---------------- DESCRIPTION ----------------
            TextField(
              decoration: const InputDecoration(labelText: 'Description'),
              maxLines: 3,
              onChanged: notifier.setDescription,
            ),

            const SizedBox(height: 20),

            // ---------------- ADD MODULE BUTTON ----------------
            CustomElevatedButton(
              onPress: () {
                final newModule = ModuleModel(id: const Uuid().v4(), title: 'New Module', lessons: []);

                notifier.addModule(newModule);
              },
              title: 'Add Module',
            ),

            const SizedBox(height: 20),

            // ---------------- MODULE LIST ----------------
            Expanded(
              child: ListView.builder(
                itemCount: draft.modules.length,
                itemBuilder: (context, index) {
                  final module = draft.modules[index];

                  return Card(
                    child: ExpansionTile(
                      title: Text(module.title),

                      children: [
                        // ---- Add Lesson Button ----
                        TextButton(
                          onPressed: () {
                            final lesson = LessonModel(
                              id: const Uuid().v4(),
                              title: 'New Lesson',
                              type: 'video',
                              durationMinutes: 5,
                              isFree: false,
                              content: '',
                            );

                            notifier.addLesson(module.id, lesson);
                          },
                          child: const Text('Add Lesson'),
                        ),

                        // ---- Lessons List ----
                        ...module.lessons.map((lesson) {
                          return ListTile(
                            title: Text(lesson.title),
                            subtitle: Text(lesson.type),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                notifier.removeLesson(module.id, lesson.id);
                              },
                            ),
                          );
                        }),
                      ],
                    ),
                  );
                },
              ),
            ),

            // ---------------- SAVE BUTTON ----------------
            CustomElevatedButton(
              onPress: () async {
                final draft = ref.read(createCourseProvider);

                final course = draft.toCourse(instructorId: "instructor_123", instructorName: "John Doe");

                await FirebaseFirestoreServices().saveCourseToFirebase(course);

                ShowSnackbar1.success(context, 'Course Saved');

                notifier.clear();
                context.go(Routes.home);
              },
              title: 'Save Course',
            ),
          ],
        ),
      ),
    );
  }
}
