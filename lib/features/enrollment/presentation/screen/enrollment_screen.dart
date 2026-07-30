import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_assets.dart';
import 'package:lms/core/routing/app_routing.dart';
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
  final _formKey = GlobalKey<FormState>();
  final _nameOnCardController = TextEditingController();
  final _cardNumberController = TextEditingController();
  final _cvcController = TextEditingController();
  final _expiryDateController = TextEditingController();

  // ✅ Track selected payment method (null means "Add New Credit Card")
  String? _selectedPaymentMethodId;
  String selectedPaymentMethodLabel = 'Add New Credit Card';

  @override
  void dispose() {
    _nameOnCardController.dispose();
    _cardNumberController.dispose();
    _cvcController.dispose();
    _expiryDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final enrollment = ref.watch(enrollmentProvider);

    if (enrollment == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go(Routes.home);
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () {
            if (enrollment.currentStep > 1) {
              ref.read(enrollmentProvider.notifier).previousStep();
            } else {
              context.pop();
            }
          },
        ),
        title: const Text(
          'Enrollment',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress Stepper
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ProgressStepper(
                currentStep: enrollment.currentStep,
                steps: const ['Overview', 'Payment Method', 'Confirmation'],
              ),
            ),
            const SizedBox(height: 24),
            // Step Content
            Expanded(child: _buildStepContent(enrollment)),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButton(enrollment),
    );
  }

  Widget _buildStepContent(EnrollmentModel enrollment) {
    switch (enrollment.currentStep) {
      case 1:
        return _buildOverviewStep(enrollment);
      case 2:
        return _buildPaymentMethodStep(enrollment);
      case 3:
        return _buildTransactionCompletedStep(enrollment);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildOverviewStep(EnrollmentModel enrollment) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Overview', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          // Course Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Course Name: ${enrollment.courseName}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.play_circle_outline, color: Colors.grey[700], size: 20),
                          const SizedBox(width: 8),
                          Text('${enrollment.totalLectures}+ Lectures'),
                        ],
                      ),
                    ),
                    if (enrollment.hasCertificate)
                      Expanded(
                        child: Row(
                          children: [
                            Icon(Icons.verified_user, color: Colors.grey[700], size: 20),
                            const SizedBox(width: 8),
                            const Text('Certificate'),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.schedule, color: Colors.grey[700], size: 20),
                          const SizedBox(width: 8),
                          Text(enrollment.duration),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        children: [
                          Icon(Icons.local_offer, color: Colors.grey[700], size: 20),
                          const SizedBox(width: 8),
                          Text('${enrollment.discountPercentage.toInt()}% Off'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildDetailRow('Course Rating', '★★★★★'),
          const SizedBox(height: 12),
          _buildDetailRow('Course Time', enrollment.duration),
          const SizedBox(height: 12),
          _buildDetailRow('Course Trainer', enrollment.instructorName),
          const SizedBox(height: 24),
          PurchaseDetailsCard(
            date: enrollment.formattedDate,
            originalPrice: enrollment.originalPrice,
            couponCode: enrollment.couponCode,
            finalPrice: enrollment.finalPrice,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodStep(EnrollmentModel enrollment) {
    // ✅ Watch saved payment methods
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

            // ✅ 1. Show Saved Payment Methods (if any)
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
                      selectedPaymentMethodLabel = method.typeLabel;
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
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                method.displayName,
                                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected) const Icon(Icons.check_circle, color: Colors.blue, size: 24),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],

            // ✅ 2. "Add New Credit Card" Option (Always visible)
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPaymentMethodId = null;
                  selectedPaymentMethodLabel = 'Add New Credit Card';
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
                    const Icon(Icons.add_circle_outline, color: Colors.black87, size: 24),
                    const SizedBox(width: 16),
                    const Text(
                      'Add New Credit Card',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                    ),
                    const Spacer(),
                    if (_selectedPaymentMethodId == null)
                      const Icon(Icons.check_circle, color: Colors.blue, size: 24),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ✅ 3. Credit Card Form (Only shown if "Add New Credit Card" is selected)
            if (_selectedPaymentMethodId == null) ...[
              const Text('Card Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 16),

              // Name on Card
              _buildTextField(
                controller: _nameOnCardController,
                label: 'Name on Card',
                icon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Please enter cardholder name';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Card Number
              _buildTextField(
                controller: _cardNumberController,
                label: 'Card Number',
                icon: Icons.credit_card,
                keyboardType: TextInputType.number,
                maxLength: 19,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, CardNumberInputFormatter()],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Please enter card number';
                  if (value.replaceAll(' ', '').length < 16) return 'Please enter a valid card number';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // CVC and Expiry Date in a row
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
                        if (value == null || value.trim().isEmpty) return 'Required';
                        if (value.length < 3) return 'Invalid CVC';
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
                        if (value == null || value.trim().isEmpty) return 'Required';
                        if (value.length < 5) return 'Invalid date';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Purchase Details
            PurchaseDetailsCard(
              date: enrollment.formattedDate,
              originalPrice: enrollment.originalPrice,
              couponCode: enrollment.couponCode,
              finalPrice: enrollment.finalPrice,
            ),
          ],
        ),
      ),
    );
  }

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

  Widget _buildTransactionCompletedStep(EnrollmentModel enrollment) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Transaction Completed!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
          ),
          const SizedBox(height: 40),
          Center(child: Image(image: AssetImage(AppIcons.transactionSuccess))),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text('$label :', style: const TextStyle(fontSize: 16, color: Colors.black87)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildBottomButton(EnrollmentModel enrollment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              if (enrollment.currentStep == 1) {
                // Step 1: Overview → Go to Step 2 (Payment)
                ref.read(enrollmentProvider.notifier).nextStep();
              } else if (enrollment.currentStep == 2) {
                // Step 2: Payment → Validate and go to Step 3 (Success)
                if (_selectedPaymentMethodId == null) {
                  // Adding a new card, validate the form
                  if (_formKey.currentState!.validate()) {
                    ref.read(enrollmentProvider.notifier).nextStep();
                  }
                } else {
                  // Using a saved card, skip validation and proceed
                  ref.read(enrollmentProvider.notifier).nextStep();
                }
              } else if (enrollment.currentStep == 3) {
                // Step 3: Success → Go to Home
                context.go(Routes.home);
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (mounted) {
                    ref.read(enrollmentProvider.notifier).reset();
                  }
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}

// Input Formatter for Card Number (adds space every 4 digits)
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonZeroIndex = i + 1;
      if (nonZeroIndex % 4 == 0 && nonZeroIndex != text.length) {
        buffer.write(' ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
      text: string,
      selection: TextSelection.collapsed(offset: string.length),
    );
  }
}

// Input Formatter for Expiry Date (adds / after MM)
class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;

    if (newValue.selection.baseOffset == 0) {
      return newValue;
    }

    if (text.length == 2 && oldValue.text.length == 1) {
      text += '/';
    }

    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}
