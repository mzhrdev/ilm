import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/data/services/firebase_firestore_services.dart';
import 'package:lms/core/presentation/widgets/custom_elevated_button.dart';
import 'package:lms/core/presentation/widgets/custom_icon_button.dart';
import 'package:lms/core/presentation/widgets/custom_safe_area.dart';
import 'package:lms/core/presentation/widgets/custom_text_button.dart';
import 'package:lms/core/presentation/widgets/custom_text_field.dart';
import 'package:lms/core/presentation/widgets/snackbar.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/auth/data/providers/current_user_provider.dart';
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
    final currentUser = ref.read(currentUserProvider);

    return CustomSafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Create Course', style: AppTextStyle.kHeading),
          leading: CustomIconButton(
            onTap: () {
              context.go(Routes.home);
            },
            icon: Icons.arrow_back_ios_new,
            iconColor: AppColors.kBlack,
            paddingAroundIcon: context.w(4.5),
          ),
        ),

        body: SingleChildScrollView(
          padding: EdgeInsets.all(context.w(5)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Course Title
              Text("Course Title", style: AppTextStyle.kBodyMedium),
              CustomTextField(
                controller: TextEditingController(),
                hintText: "e.g: Operating System",
                labelText: null,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                validator: FieldValidator.required(),
                onChanged: notifier.setTitle,
              ),
              SizedBox(height: context.h(2)),
              // Course Description
              Text("Description", style: AppTextStyle.kBodyMedium),
              CustomTextField(
                controller: TextEditingController(),
                hintText: "Why?.....",
                labelText: null,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                validator: FieldValidator.required(),
                onChanged: notifier.setDescription,
                maxLength: 2,
              ),
              SizedBox(height: context.h(2)),
              // Course Category
              Text("Category", style: AppTextStyle.kBodyMedium),
              CustomTextField(
                controller: TextEditingController(),
                hintText: "e.g; Tech/ Soft",
                labelText: null,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.next,
                validator: FieldValidator.required(),
                onChanged: notifier.setCategory,
                maxLength: 2,
              ),
              SizedBox(height: context.h(2)),
              // Course Price
              Text("Price", style: AppTextStyle.kBodyMedium),
              CustomTextField(
                controller: TextEditingController(),
                hintText: "e.g; in Dollars",
                labelText: null,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.next,
                validator: FieldValidator.required(),
                onChanged: (value) {
                  notifier.setPrice(double.tryParse(value) ?? 0);
                },
                maxLength: 2,
              ),
              SizedBox(height: context.h(2)),
              // Add Module Button
              CustomElevatedButton(
                onPress: () {
                  final module = ModuleModel(id: const Uuid().v4(), title: 'New Module', lessons: []);
                  notifier.addModule(module);
                },
                title: 'Add Module',
                borderRadius: context.w(2),
                elevation: 2,
              ),
              SizedBox(height: context.h(3)),
              // Course Module List
              if (draft.modules.isEmpty)
                Center(
                  child: Text('No modules added yet.', style: AppTextStyle.kBodyLarge),
                ).padSymmetric(vertical: context.h(2))
              else
                Column(
                  children: draft.modules.map((module) {
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ExpansionTile(
                        title: Text(
                          module.title,
                          style: AppTextStyle.kBodyLarge.copyWith(fontWeight: FontWeight.w600),
                        ),
                        children: [
                          // Add Lesson
                          CustomTextButton(
                            text: 'Add Lesson',
                            color: AppColors.kWhite,
                            bgColor: AppColors.kBlack,
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
                          ).centerWidget,
                          // Course Lesson List
                          if (module.lessons.isEmpty)
                            Text(
                              'No lessons added yet.',
                            ).centerWidget.padOnly(left: 16, right: 16, bottom: 16)
                          else
                            ...module.lessons.map((lesson) {
                              return ListTile(
                                leading: const Icon(Icons.play_circle_outline),
                                title: Text(lesson.title),
                                subtitle: Text(lesson.type),
                                trailing: CustomIconButton(
                                  icon: Icons.delete,
                                  iconColor: AppColors.kCallEndB,
                                  onTap: () {
                                    notifier.removeLesson(module.id, lesson.id);
                                  },
                                ),
                              );
                            }),

                          const SizedBox(height: 8),
                        ],
                      ),
                    );
                  }).toList(),
                ),

              SizedBox(height: context.h(5)),
              // Save Course Button
              CustomElevatedButton(
                onPress: () async {
                  final draft = ref.read(createCourseProvider);
                  if (!draft.isValid) {
                    ShowSnackbar1.error(context, 'Please complete course details');
                    return;
                  }
                  if (currentUser == null) {
                    ShowSnackbar1.error(context, 'Unable to identify instructor');
                    return;
                  }
                  try {
                    await FirebaseFirestoreServices().saveCourseFromDraft(
                      draft: draft,
                      instructorId: currentUser.id,
                      instructorName: currentUser.name,
                    );
                    if (!context.mounted) return;
                    ShowSnackbar1.success(context, 'Course Saved');
                    ref.read(createCourseProvider.notifier).clear();
                    context.go(Routes.home);
                  } catch (e) {
                    if (!context.mounted) return;
                    ShowSnackbar1.error(context, 'Failed to save course');
                  }
                },
                title: 'Save Course',
                borderRadius: context.w(2),
                elevation: 2,
              ),
              SizedBox(height: context.h(3)),
            ],
          ),
        ),
      ),
    );
  }
}
