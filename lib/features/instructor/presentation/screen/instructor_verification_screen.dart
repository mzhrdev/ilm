import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/data/services/firebase_firestore_services.dart';
import 'package:lms/core/presentation/widgets/custom_elevated_button.dart';
import 'package:lms/core/presentation/widgets/custom_safe_area.dart';
import 'package:lms/core/presentation/widgets/snackbar.dart';
import 'package:lms/core/routing/app_routing.dart';

class InstructorVerificationScreen extends ConsumerStatefulWidget {
  const InstructorVerificationScreen({super.key});

  @override
  ConsumerState<InstructorVerificationScreen> createState() => _InstructorVerificationScreenState();
}

class _InstructorVerificationScreenState extends ConsumerState<InstructorVerificationScreen> {
  // Form Key
  final _formKey = GlobalKey<FormState>();
  // Text Editing Controller
  final _instructorIdController = TextEditingController();
  final _instructorNameController = TextEditingController();
  // Bool Flag for Loading
  bool _isLoading = false;

  // Dispose Method
  @override
  void dispose() {
    _instructorIdController.dispose();
    _instructorNameController.dispose();
    super.dispose();
  }

  // Verify Instructor Method
  Future<void> _verifyInstructor() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoading = true;
    });

    try {
      final instructorId = _instructorIdController.text.trim();
      final instructorName = _instructorNameController.text.trim();
      final firestoreService = FirebaseFirestoreServices();
      // Verify instructor against Firestore
      final isVerified = await firestoreService.verifyInstructor(
        instructorId: instructorId,
        instructorName: instructorName,
      );
      if (!isVerified) {
        if (mounted) {
          ShowSnackbar1.error(context, 'Invalid Instructor ID or Name.');
        }
        return;
      }
      // Update current user's role
      await firestoreService.updateUserRole('instructor');
      if (!mounted) return;
      ShowSnackbar1.success(context, 'Instructor verified successfully.');
      // Navigate to Create Course
      context.push(Routes.createCourse);
    } catch (e) {
      if (!mounted) return;
      ShowSnackbar1.error(context, e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomSafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text('Instructor Verification', style: AppTextStyle.kHeading)),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(context.w(4.5)),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: context.h(3)),
                const Text('Become an Instructor', style: AppTextStyle.kHeading),
                SizedBox(height: context.h(1.5)),

                Text(
                  'Enter your instructor credentials to verify '
                  'your instructor account.',
                  style: AppTextStyle.kBodyLarge.copyWith(color: AppColors.kBlack.withAlpha(100)),
                ),

                const SizedBox(height: 35),

                // Instructor ID
                TextFormField(
                  controller: _instructorIdController,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Instructor ID',
                    hintText: 'Enter your instructor ID',
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your Instructor ID';
                    }
                    return null;
                  },
                ),

                SizedBox(height: context.h(2)),

                // Instructor Name
                TextFormField(
                  controller: _instructorNameController,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) {
                    if (!_isLoading) {
                      _verifyInstructor();
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Instructor Name',
                    hintText: 'Enter your instructor name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your Instructor Name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.h(3.5)),

                // Submit
                CustomElevatedButton(
                  bWidth: context.w(97),
                  borderRadius: context.w(3),
                  onPress: _isLoading ? null : _verifyInstructor,
                  title: _isLoading ? 'Verifying...' : 'Verify Instructor',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
