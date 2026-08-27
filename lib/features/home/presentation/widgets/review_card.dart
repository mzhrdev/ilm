import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/features/home/data/model/review_model.dart';

class ReviewCard extends StatelessWidget {
  final ReviewModel review;

  const ReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: context.h(2)),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.kGrey.withAlpha(100),
        borderRadius: BorderRadius.circular(context.w(4)),
      ),
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
                          errorBuilder: (_, __, ___) =>
                              Icon(Icons.person, color: AppColors.kBlack.withAlpha(150)),
                        ),
                      )
                    : Icon(Icons.person, color: AppColors.kBlack.withAlpha(150)),
              ),
              SizedBox(width: context.w(4)),
              // Name and Label
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(review.userName, style: AppTextStyle.kBodyLarge),
                    SizedBox(height: context.h(0.5)),
                    Text('Student', style: AppTextStyle.kBodyMedium),
                  ],
                ),
              ),
              // Rating
              Row(
                children: [
                  ...List.generate(5, (index) {
                    return Icon(
                      index < review.rating.floor() ? Icons.star : Icons.star_border,
                      color: AppColors.kAmber,
                      size: context.h(4),
                    );
                  }),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Review Comment
          Text(review.comment, style: AppTextStyle.kBodySmall),
        ],
      ),
    );
  }
}
