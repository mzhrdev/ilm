class EnrollmentModel {
  final String courseId;
  final String userId;
  final String courseName;
  final String instructorName;
  final int totalLectures;
  final String duration;
  final double originalPrice;
  final double discountPercentage;
  final double finalPrice;
  final String couponCode;
  final DateTime purchaseDate;
  final int currentStep;
  final bool hasCertificate;
  final double progress; // 0.0 to 1.0

  EnrollmentModel({
    required this.courseId,
    required this.userId,
    required this.courseName,
    required this.instructorName,
    required this.totalLectures,
    required this.duration,
    required this.originalPrice,
    required this.discountPercentage,
    required this.finalPrice,
    required this.couponCode,
    required this.purchaseDate,
    required this.progress,
    this.currentStep = 1,
    this.hasCertificate = true,
  });

  String get formattedDate =>
      '${purchaseDate.day.toString().padLeft(2, '0')}/${purchaseDate.month.toString().padLeft(2, '0')}/${purchaseDate.year}';

  EnrollmentModel copyWith({
    String? courseId,
    String? userId,
    String? courseName,
    String? instructorName,
    int? totalLectures,
    String? duration,
    double? originalPrice,
    double? discountPercentage,
    double? finalPrice,
    String? couponCode,
    DateTime? purchaseDate,
    int? currentStep,
    bool? hasCertificate,
    double? progress,
  }) {
    return EnrollmentModel(
      courseId: courseId ?? this.courseId,
      userId: userId ?? this.userId,
      courseName: courseName ?? this.courseName,
      instructorName: instructorName ?? this.instructorName,
      totalLectures: totalLectures ?? this.totalLectures,
      duration: duration ?? this.duration,
      originalPrice: originalPrice ?? this.originalPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      finalPrice: finalPrice ?? this.finalPrice,
      couponCode: couponCode ?? this.couponCode,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      currentStep: currentStep ?? this.currentStep,
      hasCertificate: hasCertificate ?? this.hasCertificate,
      progress: progress ?? this.progress,
    );
  }
}
