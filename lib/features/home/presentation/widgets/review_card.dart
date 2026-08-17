import 'package:flutter/material.dart';
import 'package:Edvance/features/home/data/model/review_model.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Rating
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[300],
                child: review.userAvatar != null
                    ? ClipOval(
                        child: Image.network(
                          review.userAvatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(Icons.person, color: Colors.grey),
                        ),
                      )
                    : const Icon(Icons.person, color: Colors.grey),
              ),
              const SizedBox(width: 12),
              // Name and Label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text('Student', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              // Rating
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < review.rating.floor() ? Icons.star : Icons.star_border,
                      color: Colors.amber[700],
                      size: 18,
                    );
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Review Comment
          Text(review.comment, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4)),
        ],
      ),
    );
  }
}
