import 'package:cloud_firestore/cloud_firestore.dart';

class EnrollmentModel {
  // ---------------------------------------------------------------------------
  // Identity
  // ---------------------------------------------------------------------------

  final String courseId;
  final String userId;

  // ---------------------------------------------------------------------------
  // Purchase Information
  // ---------------------------------------------------------------------------

  /// Price of the course before discount at the time of purchase.
  final double originalPrice;

  /// Discount applied at the time of purchase.
  final double discountPercentage;

  /// Actual amount paid by the student.
  final double paidAmount;

  /// Coupon used during purchase, if any.
  final String? couponCode;

  final DateTime purchaseDate;

  // ---------------------------------------------------------------------------
  // Learning Progress
  // ---------------------------------------------------------------------------

  /// Current lesson/step the student is on.
  final int currentStep;

  /// Whether the student has earned/completed the certificate.
  final bool hasCertificate;

  /// Learning progress from 0.0 to 1.0.
  final double progress;

  const EnrollmentModel({
    required this.courseId,
    required this.userId,
    required this.originalPrice,
    required this.discountPercentage,
    required this.paidAmount,
    required this.couponCode,
    required this.purchaseDate,
    required this.progress,
    this.currentStep = 0,
    this.hasCertificate = true,
  });

  // ---------------------------------------------------------------------------
  // Computed
  // ---------------------------------------------------------------------------

  String get formattedDate {
    return '${purchaseDate.day.toString().padLeft(2, '0')}/'
        '${purchaseDate.month.toString().padLeft(2, '0')}/'
        '${purchaseDate.year}';
  }

  // ---------------------------------------------------------------------------
  // Copy With
  // ---------------------------------------------------------------------------

  EnrollmentModel copyWith({
    String? courseId,
    String? userId,
    double? originalPrice,
    double? discountPercentage,
    double? paidAmount,
    String? couponCode,
    DateTime? purchaseDate,
    int? currentStep,
    bool? hasCertificate,
    double? progress,
  }) {
    return EnrollmentModel(
      courseId: courseId ?? this.courseId,
      userId: userId ?? this.userId,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      paidAmount: paidAmount ?? this.paidAmount,
      couponCode: couponCode ?? this.couponCode,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      currentStep: currentStep ?? this.currentStep,
      hasCertificate: hasCertificate ?? this.hasCertificate,
      progress: progress ?? this.progress,
    );
  }

  // ---------------------------------------------------------------------------
  // From Firestore
  // ---------------------------------------------------------------------------

  factory EnrollmentModel.fromFirestore(Map<String, dynamic> data) {
    return EnrollmentModel(
      courseId: data['courseId'] ?? '',
      userId: data['userId'] ?? '',

      originalPrice: (data['originalPrice'] ?? 0).toDouble(),

      discountPercentage: (data['discountPercentage'] ?? 0).toDouble(),

      paidAmount: (data['paidAmount'] ?? 0).toDouble(),

      couponCode: data['couponCode'],

      purchaseDate: data['purchaseDate'] is Timestamp
          ? (data['purchaseDate'] as Timestamp).toDate()
          : DateTime.now(),

      currentStep: data['currentStep'] ?? 0,

      hasCertificate: data['hasCertificate'] ?? false,

      progress: (data['progress'] ?? 0).toDouble(),
    );
  }

  // ---------------------------------------------------------------------------
  // To Firestore
  // ---------------------------------------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'courseId': courseId,
      'userId': userId,

      'originalPrice': originalPrice,
      'discountPercentage': discountPercentage,
      'paidAmount': paidAmount,
      'couponCode': couponCode,
      'purchaseDate': Timestamp.fromDate(purchaseDate),

      'currentStep': currentStep,
      'hasCertificate': hasCertificate,
      'progress': progress,
    };
  }
}
