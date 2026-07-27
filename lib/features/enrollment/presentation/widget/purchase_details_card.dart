// lib/features/enrollment/presentation/widgets/purchase_details_card.dart

import 'package:flutter/material.dart';

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Purchase Details',
            style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Date: $date', style: const TextStyle(fontSize: 14)),
              Text(
                'Price: ${originalPrice.toStringAsFixed(0)}\$',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Coupon: $couponCode', style: TextStyle(fontSize: 14, color: Colors.green[700])),
              Text(
                'Final Price: ${finalPrice.toStringAsFixed(0)}\$',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
