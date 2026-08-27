import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_assets.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/custom_elevated_button.dart';
import 'package:lms/core/presentation/widgets/custom_icon_button.dart';
import 'package:lms/core/presentation/widgets/custom_safe_area.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/courses/data/model/course_model.dart';
import 'package:lms/features/courses/data/provider/course_provider.dart';
import 'package:lms/features/enrollment/data/model/enrollment_model.dart';
import 'package:lms/features/enrollment/data/provider/enrollment_provider.dart';
import 'package:lms/features/enrollment/presentation/widget/progress_stepper.dart';
import 'package:lms/features/enrollment/presentation/widget/purchase_details_card.dart';
import 'package:lms/features/payment/data/provider/payment_method_provider.dart';

class EnrollmentScreen extends ConsumerStatefulWidget {
  const EnrollmentScreen({super.key});

  @override
  ConsumerState<EnrollmentScreen> createState() => _EnrollmentScreenState();
}

class _EnrollmentScreenState extends ConsumerState<EnrollmentScreen> {
  // Form Key
  final _formKey = GlobalKey<FormState>();
  // Text Editing Controller
  final _nameOnCardController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cvcController = TextEditingController();
  final _expiryDateController = TextEditingController();

  String? _selectedPaymentMethodId;

  // Dispose Method
  @override
  void dispose() {
    _nameOnCardController.dispose();
    _cardNumberController.dispose();
    _cvcController.dispose();
    _expiryDateController.dispose();

    super.dispose();
  }

  // Build Function
  @override
  Widget build(BuildContext context) {
    final enrollment = ref.watch(enrollmentProvider);
    // If Enrollment is Null
    if (enrollment == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.go(Routes.home);
        }
      });

      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ref
        .watch(coursesProvider)
        .when(
          // Loading...
          loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
          // On Error
          error: (error, stack) => CustomSafeArea(
            child: Scaffold(
              appBar: AppBar(title: const Text('Enrollment')),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: context.h(8), color: AppColors.kCallEndB),
                    const SizedBox(height: 16),
                    const Text('Unable to load course', style: AppTextStyle.kBodyLarge),
                    SizedBox(height: context.h(2.5)),
                    Text(error.toString(), textAlign: TextAlign.center),
                    SizedBox(height: context.h(4)),
                    CustomElevatedButton(
                      title: 'Retry',
                      onPress: () => ref.invalidate(coursesProvider),
                      elevation: 2,
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Actual Course Data
          data: (courses) {
            CourseModel? course;

            // Debug Statements and Loops
            debugPrint('===== COURSES LOADED IN ENROLLMENT SCREEN =====');
            debugPrint('Enrollment courseId: ${enrollment.courseId}');
            for (final course in courses) {
              debugPrint(
                'Course ID: ${course.id} | '
                'Title: ${course.title}',
              );
            }
            for (final item in courses) {
              if (item.id == enrollment.courseId) {
                course = item;
                break;
              }
            }
            // NO Course Available
            if (course == null) {
              return Scaffold(
                appBar: AppBar(title: const Text('Enrollment', style: AppTextStyle.kHeading)),
                body: const Center(child: Text('Course not found.', style: AppTextStyle.kSectionTitle)),
              );
            }
            // Enrollment Screen Builder Method Called
            return _buildEnrollmentScreen(enrollment: enrollment, course: course);
          },
        );
  }

  // Enrollment Screen Builder Method Definition
  Widget _buildEnrollmentScreen({required EnrollmentModel enrollment, required CourseModel course}) {
    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,

        appBar: AppBar(
          backgroundColor: AppColors.kWhite,
          elevation: 0,
          leading: CustomIconButton(
            onTap: () {
              if (enrollment.currentStep > 1) {
                ref.read(enrollmentProvider.notifier).previousStep();
              } else {
                context.pop();
              }
            },
            icon: Icons.arrow_back_ios_new,
            iconColor: AppColors.kBlack,
            paddingAroundIcon: context.w(4.5),
          ),

          title: const Text('Enrollment', style: AppTextStyle.kHeading),
        ),

        body: Column(
          children: [
            // Current Step Showing (e.g; currently at Overview Tab)
            ProgressStepper(
              currentStep: enrollment.currentStep,
              steps: const ['Overview', 'Payment Method', 'Confirmation'],
            ).padSymmetric(horizontal: context.w(6)),
            SizedBox(height: context.h(3)),
            // Content of Current Step Builder Method Called
            Expanded(
              child: _buildStepContent(enrollment: enrollment, course: course),
            ),
          ],
        ),
        // Bottom Button
        bottomNavigationBar: _buildBottomButton(enrollment),
      ),
    );
  }

  // Content of Current Step Builder Method Definition
  Widget _buildStepContent({required EnrollmentModel enrollment, required CourseModel course}) {
    switch (enrollment.currentStep) {
      case 1:
        // OverView Tab Builder Method Called
        return _buildOverviewStep(enrollment, course);

      case 2:
        // Payment Tab Builder Method Called
        return _buildPaymentMethodStep(enrollment);

      case 3:
        // Completed Tab Builder Method Called
        return _buildTransactionCompletedStep(enrollment);

      default:
        return const SizedBox.shrink();
    }
  }

  // OverView Tab Builder Method Definition
  Widget _buildOverviewStep(EnrollmentModel enrollment, CourseModel course) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(context.w(4)),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview Heading
          const Text('Overview', style: AppTextStyle.kDisplayTitle),
          SizedBox(height: context.h(2)),
          // Course Info Card
          Container(
            padding: EdgeInsets.all(context.w(4)),
            decoration: BoxDecoration(
              color: AppColors.kGrey,
              borderRadius: BorderRadius.circular(context.w(5)),
            ),

            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Course Name
                Text('Course Name: ${course.title}', style: AppTextStyle.kSectionTitle),
                SizedBox(height: context.h(1.5)),

                Row(
                  children: [
                    // Lectures & Certificate
                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.play_circle_outline,
                            color: AppColors.kBlack.withAlpha(160),
                            size: context.h(2.75),
                          ),
                          SizedBox(width: context.w(2)),

                          Text('${course.totalLessons} Lectures', style: AppTextStyle.kBodyMedium),
                        ],
                      ),
                    ),

                    if (enrollment.hasCertificate)
                      Expanded(
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified_user,
                              color: AppColors.kBlack.withAlpha(160),
                              size: context.h(2.75),
                            ),

                            SizedBox(width: context.w(2)),

                            const Text('Certificate', style: AppTextStyle.kBodyMedium),
                          ],
                        ),
                      ),
                  ],
                ),

                SizedBox(height: context.h(1.5)),

                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.schedule, color: AppColors.kBlack.withAlpha(160), size: context.h(2.75)),

                          SizedBox(width: context.w(2)),

                          Text(_formatDuration(course.totalDurationMinutes), style: AppTextStyle.kBodyMedium),
                        ],
                      ),
                    ),

                    Expanded(
                      child: Row(
                        children: [
                          Icon(
                            Icons.local_offer,
                            color: AppColors.kBlack.withAlpha(160),
                            size: context.h(2.75),
                          ),

                          SizedBox(width: context.w(2)),

                          Text(
                            '${enrollment.discountPercentage.toInt()}% Off',
                            style: AppTextStyle.kBodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: context.h(3)),
          // Course Detail Column
          _buildDetailRow('Course Rating', course.rating.toStringAsFixed(1)),
          SizedBox(height: context.h(1.5)),
          _buildDetailRow('Course Time', _formatDuration(course.totalDurationMinutes)),
          SizedBox(height: context.h(1.5)),
          _buildDetailRow('Course Trainer', course.instructorName),
          SizedBox(height: context.h(3)),
          
          // Purchase Details Card
          PurchaseDetailsCard(
            date: enrollment.formattedDate,
            originalPrice: enrollment.originalPrice,
            couponCode: enrollment.couponCode ?? 'None',
            finalPrice: enrollment.paidAmount,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 2 - PAYMENT
  // ---------------------------------------------------------------------------

  Widget _buildPaymentMethodStep(EnrollmentModel enrollment) {
    final savedMethods = ref.watch(paymentMethodsProvider).methods;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Form(
        key: _formKey,

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Payment Method', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

            const SizedBox(height: 24),

            if (savedMethods.isNotEmpty) ...[
              const Text(
                'Saved Methods',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
              ),

              const SizedBox(height: 12),

              ...savedMethods.map((method) {
                final isSelected = _selectedPaymentMethodId == method.id;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethodId = method.id;
                    });
                  },

                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),

                    padding: const EdgeInsets.all(16),

                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue[50] : Colors.grey[100],

                      borderRadius: BorderRadius.circular(12),

                      border: Border.all(color: isSelected ? Colors.blue : Colors.transparent, width: 1.5),
                    ),

                    child: Row(
                      children: [
                        Icon(method.icon, color: Colors.black87, size: 24),

                        const SizedBox(width: 16),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method.typeLabel,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),

                              const SizedBox(height: 4),

                              Text(
                                method.displayName,
                                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),

                        if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),
            ],

            // Add new card
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPaymentMethodId = null;
                });
              },

              child: Container(
                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  color: _selectedPaymentMethodId == null ? Colors.blue[50] : Colors.grey[100],

                  borderRadius: BorderRadius.circular(12),

                  border: Border.all(
                    color: _selectedPaymentMethodId == null ? Colors.blue : Colors.transparent,

                    width: 1.5,
                  ),
                ),

                child: Row(
                  children: [
                    const Icon(Icons.add_circle_outline, size: 24),

                    const SizedBox(width: 16),

                    const Text(
                      'Add New Credit Card',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),

                    const Spacer(),

                    if (_selectedPaymentMethodId == null) const Icon(Icons.check_circle, color: Colors.blue),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            if (_selectedPaymentMethodId == null) ...[
              const Text('Card Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),

              const SizedBox(height: 16),

              _buildTextField(
                controller: _nameOnCardController,
                label: 'Name on Card',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter cardholder name';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              _buildTextField(
                controller: _cardNumberController,
                label: 'Card Number',
                icon: Icons.credit_card,
                keyboardType: TextInputType.number,
                maxLength: 19,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, CardNumberInputFormatter()],
                validator: (value) {
                  final cardNumber = value?.replaceAll(' ', '') ?? '';

                  if (cardNumber.isEmpty) {
                    return 'Please enter card number';
                  }

                  if (cardNumber.length < 16) {
                    return 'Please enter a valid card number';
                  }

                  return null;
                },
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _cvcController,
                      label: 'CVC Number',
                      icon: Icons.lock_outline,
                      keyboardType: TextInputType.number,
                      maxLength: 3,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }

                        if (value.length < 3) {
                          return 'Invalid CVC';
                        }

                        return null;
                      },
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildTextField(
                      controller: _expiryDateController,
                      label: 'Expiry Date',
                      icon: Icons.calendar_today,
                      hintText: 'MM/YY',
                      keyboardType: TextInputType.number,
                      maxLength: 5,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, ExpiryDateInputFormatter()],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }

                        if (value.length < 5) {
                          return 'Invalid date';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            PurchaseDetailsCard(
              date: enrollment.formattedDate,
              originalPrice: enrollment.originalPrice,
              couponCode: enrollment.couponCode ?? 'None',
              finalPrice: enrollment.paidAmount,
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TEXT FIELD
  // ---------------------------------------------------------------------------

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hintText,
    TextInputType? keyboardType,
    int? maxLength,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),

      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),

      child: TextFormField(
        controller: controller,

        decoration: InputDecoration(
          labelText: label,
          hintText: hintText,
          border: InputBorder.none,

          prefixIcon: Icon(icon, color: Colors.grey[600], size: 20),
        ),

        keyboardType: keyboardType,
        maxLength: maxLength,
        inputFormatters: inputFormatters,
        validator: validator,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // STEP 3
  // ---------------------------------------------------------------------------

  Widget _buildTransactionCompletedStep(EnrollmentModel enrollment) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,

        children: [
          const SizedBox(height: 20),

          const Text('Transaction Completed!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),

          const SizedBox(height: 40),

          Center(child: Image(image: AssetImage(AppIcons.transactionSuccess))),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // BOTTOM BUTTON
  // ---------------------------------------------------------------------------

  Widget _buildBottomButton(EnrollmentModel enrollment) {
    String buttonText;

    switch (enrollment.currentStep) {
      case 1:
        buttonText = 'Continue to Payment';
        break;

      case 2:
        buttonText = 'Pay & Enroll';
        break;

      case 3:
        buttonText = 'Start Learning';
        break;

      default:
        buttonText = 'Continue';
    }

    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),

      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,

          child: ElevatedButton(
            onPressed: () async {
              final notifier = ref.read(enrollmentProvider.notifier);

              if (enrollment.currentStep == 1) {
                notifier.nextStep();
                return;
              }

              if (enrollment.currentStep == 2) {
                if (_selectedPaymentMethodId == null) {
                  if (!_formKey.currentState!.validate()) {
                    return;
                  }
                }

                /*
                 * IMPORTANT:
                 * This is currently where the real payment service
                 * should be called.
                 *
                 * After successful payment:
                 * 1. Create Enrollment in Firestore.
                 * 2. Move to step 3.
                 */
                await notifier.saveEnrollment();
                notifier.nextStep();
                return;
              }

              if (enrollment.currentStep == 3) {
                context.go(Routes.home);

                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted) {
                    notifier.reset();
                  }
                });
              }
            },

            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,

              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),

            child: Text(
              buttonText,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // HELPERS
  // ---------------------------------------------------------------------------

  Widget _buildDetailRow(String label, String value) {
    return Row(
      children: [
        Text('$label: ', style: AppTextStyle.kBodyLarge),

        Expanded(
          child: Text(value, style: AppTextStyle.kBodyMedium.copyWith(fontWeight: FontWeight.w800)),
        ),
      ],
    );
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    }

    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (remainingMinutes == 0) {
      return '$hours hr';
    }

    return '$hours hr $remainingMinutes min';
  }
}

// -----------------------------------------------------------------------------
// CARD NUMBER FORMATTER
// -----------------------------------------------------------------------------

class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);

      final position = i + 1;

      if (position % 4 == 0 && position != text.length) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// -----------------------------------------------------------------------------
// EXPIRY DATE FORMATTER
// -----------------------------------------------------------------------------

class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (text.length == 2 && oldValue.text.length == 1) {
      text += '/';
    }

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
