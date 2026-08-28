// lib/features/profile/presentation/screens/edit_profile_screen.dart

import 'dart:io';

import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/custom_icon_button.dart';
import 'package:lms/core/presentation/widgets/custom_safe_area.dart';
import 'package:lms/core/presentation/widgets/snackbar.dart';
import 'package:lms/features/auth/data/model/user_model.dart';

import '../../data/provider/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  // Form Key
  final _formKey = GlobalKey<FormState>();
  // Image Selection Variable
  File? _selectedImage;
  // Bools
  bool _isUploadingImage = false;
  bool _isSaving = false;

  // Controllers for form fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _aboutController = TextEditingController();
  final _skillsController = TextEditingController();

  // init Method
  @override
  void initState() {
    super.initState();
    // Pre-fill the form with existing user data
    final currentUser = ref.read(profileProvider).userProfile;
    if (currentUser != null) {
      _nameController.text = currentUser.name;
      _emailController.text = currentUser.email;
      _aboutController.text = currentUser.about ?? '';
      // Join skills list into a comma-separated string for the text field
      _skillsController.text = (currentUser.skills ?? []).join(', ');
    }
  }

  // Dispose Method
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _aboutController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  // Pick Image from Gallery Method Definition
  Future<void> _pickImage() async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80);

    if (pickedFile == null) return;

    final imageFile = File(pickedFile.path);

    /// Set State Method
    setState(() {
      _selectedImage = imageFile;
      _isUploadingImage = true;
    });
    try {
      await ref.read(profileProvider.notifier).updateProfileImage(imageFile);
      if (!mounted) return;
      ShowSnackbar1.success(context, 'Profile picture updated successfully!');
    } catch (e) {
      if (!mounted) return;
      ShowSnackbar1.error(context, 'Failed to update profile picture: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  //  Saving Profile Method Definition
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    final currentUser = ref.read(profileProvider).userProfile;

    /// Create updated UserModel
    final updatedUser = UserModel(
      id: currentUser?.id ?? '',
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      profileImageUrl: currentUser?.profileImageUrl, //TODO: Change to Selected Image
      about: _aboutController.text.trim(),

      /// Split comma-separated string back into a List<String>
      skills: _skillsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
    );
    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 800));
    ref.read(profileProvider.notifier).updateProfile(updatedUser);
    setState(() => _isSaving = false);
    // ignore: use_build_context_synchronously
    ShowSnackbar1.success(context, 'Profile updated successfully!');
    // ignore: use_build_context_synchronously
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final currentUser = profileState.userProfile;
    return CustomSafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.kWhite,
          elevation: 0,
          leading: CustomIconButton(
            onTap: () => context.pop(),
            icon: Icons.arrow_back_ios_new,
            iconColor: AppColors.kBlack,
            paddingAroundIcon: context.w(4.75),
          ),

          title: const Text('Edit Profile', style: AppTextStyle.kHeading),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(context.w(4)),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                SizedBox(height: context.h(3)),
                // Profile Picture Section
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: context.w(30),
                      height: context.h(13),
                      decoration: BoxDecoration(
                        color: AppColors.kGrey,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.kWhite, width: context.h(0.75)),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.kBlack.withAlpha(150),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _selectedImage != null
                            ? Image.file(
                                _selectedImage!,
                                width: context.w(30),
                                height: context.h(13),
                                fit: BoxFit.cover,
                              )
                            : currentUser?.profileImageUrl != null
                            ? Image.network(
                                currentUser!.profileImageUrl!,
                                width: context.w(30),
                                height: context.h(13),
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) {
                                  return Icon(
                                    Icons.person,
                                    size: context.h(6),
                                    color: AppColors.kBlack.withAlpha(150),
                                  );
                                },
                              )
                            : Icon(Icons.person, size: context.h(6), color: AppColors.kBlack.withAlpha(150)),
                      ),
                    ),
                    // Camera Icon to change picture
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _isUploadingImage ? null : _pickImage,
                        child: Container(
                          padding: EdgeInsets.all(context.w(3)),
                          decoration: BoxDecoration(
                            color: AppColors.kBlack,
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.kWhite, width: context.h(0.25)),
                          ),
                          child: _isUploadingImage
                              ? SizedBox(
                                  width: context.w(5),
                                  height: context.h(2),
                                  child: CircularProgressIndicator(
                                    color: AppColors.kWhite,
                                    strokeWidth: context.h(0.25),
                                  ),
                                )
                              : Icon(Icons.camera_alt, color: AppColors.kWhite, size: context.h(2)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                // Name Field
                _buildTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  icon: Icons.person_outline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.h(2)),
                // Email Field
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: context.h(2)),
                // About Me Field
                _buildTextField(
                  controller: _aboutController,
                  label: 'About Me',
                  icon: Icons.info_outline,
                  maxLines: 3,
                ),
                SizedBox(height: context.h(2)),
                // Skills Field
                _buildTextField(
                  controller: _skillsController,
                  label: 'Skills (separated by commas)',
                  icon: Icons.work_outline,
                  hintText: 'e.g. Flutter, UI/UX, Figma',
                ),
                SizedBox(height: context.h(2)),
                // Save Button
                SizedBox(
                  width: double.infinity,
                  height: context.h(5.5),
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.kBlack,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.w(4))),
                    ),
                    child: _isSaving
                        ? SizedBox(
                            width: context.w(8),
                            height: context.h(4),
                            child: CircularProgressIndicator(
                              color: AppColors.kWhite,
                              strokeWidth: context.h(0.5),
                            ),
                          )
                        : Text(
                            'Save Changes',
                            style: AppTextStyle.kBodyLarge.copyWith(color: AppColors.kWhite),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper widget to build consistent text fields
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.kGrey.withAlpha(100),
        borderRadius: BorderRadius.circular(context.w(4)),
        border: Border.all(color: AppColors.kGrey),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          labelStyle: TextStyle(color: AppColors.kBlack.withAlpha(180)),
          hintStyle: TextStyle(color: AppColors.kBlack.withAlpha(180)),
          prefixIcon: Icon(icon, color: AppColors.kBlack.withAlpha(180)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: context.w(3), vertical: context.h(1)),
        ),
      ),
    );
  }
}
