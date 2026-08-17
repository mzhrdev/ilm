import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lms/core/constants/app_colors.dart';

class CustomRatingBarIndicator extends StatelessWidget {
  const CustomRatingBarIndicator({
    super.key,
    this.itemSize = 40,
    this.rating = 0.5,
    this.color = AppColors.kBlack,
  });
  final double itemSize;
  final double rating;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return RatingBarIndicator(
      itemSize: itemSize,
      rating: rating,
      direction: Axis.horizontal,
      itemCount: 5,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(Icons.star_rounded, color: color),
    );
  }
}
