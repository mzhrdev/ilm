import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/data/services/firebase_firestore_services.dart';
import 'package:lms/core/presentation/widgets/custom_elevated_button.dart';
import 'package:lms/core/presentation/widgets/snackbar.dart';
import 'package:lms/core/routing/app_routing.dart';

class InstructorVerificationScreen extends ConsumerStatefulWidget {
  const InstructorVerificationScreen({super.key});

  @override
  ConsumerState<InstructorVerificationScreen> createState() =>
      _InstructorVerificationScreenState();
}

class _InstructorVerificationScreenState
    extends ConsumerState<InstructorVerificationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _instructorIdController = TextEditingController();
  final _instructorNameController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _instructorIdController.dispose();
    _instructorNameController.dispose();
    super.dispose();
  }

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
          ShowSnackbar1.error(
            context,
            'Invalid Instructor ID or Name.',
          );
        }
        return;
      }

      // Update current user's role
      await firestoreService.updateUserRole('instructor');

      if (!mounted) return;

      ShowSnackbar1.success(
        context,
        'Instructor verified successfully.',
      );

      // Navigate to Create Course
      context.push(Routes.createCourse);
    } catch (e) {
      if (!mounted) return;

      ShowSnackbar1.error(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Verification'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                const Text(
                  'Become an Instructor',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'Enter your instructor credentials to verify '
                  'your instructor account.',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
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

                const SizedBox(height: 20),

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

                const SizedBox(height: 30),

                // Submit
                SizedBox(
                  width: double.infinity,
                  child: CustomElevatedButton(
                    onPress: _isLoading ? null : _verifyInstructor,
                    title: _isLoading
                        ? 'Verifying...'
                        : 'Verify Instructor',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}