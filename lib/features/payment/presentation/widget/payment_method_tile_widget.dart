import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/features/payment/data/model/payment_method_model.dart';

class PaymentMethodTile extends StatelessWidget {
  final PaymentMethodModel method;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const PaymentMethodTile({
    super.key,
    required this.method,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: context.h(2.5)),
        padding: EdgeInsets.all(context.w(3)),
        decoration: BoxDecoration(
          color: AppColors.kGrey.withAlpha(80),
          borderRadius: BorderRadius.circular(context.w(4)),
          border: Border.all(color: isSelected ? AppColors.kBlack : AppColors.kGrey, width: context.h(0.15)),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: context.w(12),
              height: context.h(6),
              decoration: BoxDecoration(color: AppColors.kWhite, shape: BoxShape.circle),
              child: Icon(method.icon, color: AppColors.kBlack, size: context.h(3)),
            ),
            SizedBox(width: context.w(3.5)),
            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Method Label
                  Text(method.typeLabel, style: AppTextStyle.kBodyMedium),
                  const SizedBox(height: 4),
                  // Card Number
                  Text(
                    method.displayName,
                    style: AppTextStyle.kBodySmall.copyWith(color: AppColors.kBlack.withAlpha(80)),
                  ),
                ],
              ),
            ),

            // Selection Indicator
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected ? AppColors.kBlack : AppColors.kBlack.withAlpha(90),
              size: context.h(3),
            ),

            SizedBox(width: context.w(2.5)),

            // Delete Button
            IconButton(
              icon: Icon(Icons.delete_outline, color: AppColors.kBlack.withAlpha(90), size: context.h(3)),
              onPressed: onDelete,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}
