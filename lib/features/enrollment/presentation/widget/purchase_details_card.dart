// lib/features/enrollment/presentation/widgets/purchase_details_card.dart

import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';

class PurchaseDetailsCard extends StatelessWidget {
  final String date;
  final double originalPrice;
  final String couponCode;
  final double finalPrice;

  const PurchaseDetailsCard({
    super.key,
    required this.date,
    required this.originalPrice,
    required this.couponCode,
    required this.finalPrice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.w(4)),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.kBlack.withAlpha(150)),
        borderRadius: BorderRadius.circular(context.w(4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Purchase Details Heading
          Text(
            'Purchase Details',
            style: AppTextStyle.kBodyMedium.copyWith(color: AppColors.kBlack.withAlpha(100)),
          ),
          SizedBox(height: context.h(1.5)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Date
              Text('Date: $date', style: AppTextStyle.kBodyMedium),
              // Price (before applying coupon)
              Text('Price: ${originalPrice.toStringAsFixed(0)}\$', style: AppTextStyle.kBodyMedium),
            ],
          ),
          SizedBox(height: context.h(1.25)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Coupon (e.g; 10% off)
              Text('Coupon: $couponCode', style: AppTextStyle.kBodyMedium.copyWith(color: AppColors.kGreen)),
              // Final Price (after applying coupon)
              Text('Final Price: ${finalPrice.toStringAsFixed(0)}\$', style: AppTextStyle.kBodyMedium),
            ],
          ),
        ],
      ),
    );
  }
}
