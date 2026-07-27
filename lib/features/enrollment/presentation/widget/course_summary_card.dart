import 'package:flutter/material.dart';

class CourseSummaryCard extends StatelessWidget {
  final String courseName;
  final int totalLectures;
  final String duration;
  final bool hasCertificate;
  final int discountPercentage;

  const CourseSummaryCard({
    super.key,
    required this.courseName,
    required this.totalLectures,
    required this.duration,
    required this.hasCertificate,
    required this.discountPercentage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Course Name: $courseName',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.play_circle_outline, color: Colors.grey[700], size: 20),
                    const SizedBox(width: 8),
                    Text('$totalLectures+ Lectures'),
                  ],
                ),
              ),
              if (hasCertificate)
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
                    Text(duration),
                  ],
                ),
              ),
              Expanded(
                child: Row(
                  children: [
                    Icon(Icons.local_offer, color: Colors.grey[700], size: 20),
                    const SizedBox(width: 8),
                    Text('$discountPercentage% Off'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}