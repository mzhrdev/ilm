// lib/features/course_detail/widgets/course_info_card.dart

import 'package:flutter/material.dart';

class CourseInfoCard extends StatelessWidget {
  final int lectures;
  final String duration;
  final bool hasCertificate;
  final int discount;

  const CourseInfoCard({
    super.key,
    required this.lectures,
    required this.duration,
    required this.hasCertificate,
    required this.discount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _InfoItem(
                icon: Icons.play_circle_outline,
                label: '$lectures+ Lectures',
              ),
              _InfoItem(
                icon: Icons.schedule,
                label: duration,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              if (hasCertificate)
                _InfoItem(
                  icon: Icons.verified_user,
                  label: 'Certificate',
                ),
              _InfoItem(
                icon: Icons.local_offer,
                label: '$discount% Off',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoItem({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue[700]),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}