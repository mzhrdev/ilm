import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:lms/core/constants/app_colors.dart';

class CustomRatingBar extends StatelessWidget {
  const CustomRatingBar({
    super.key,
    this.itemSize = 40,
    this.initialRating = 5,
    this.minRating = 0.5,
    this.color = AppColors.kBlack,
    required this.onRatingUpdate,
  });
  final double itemSize;
  final double initialRating;
  final double minRating;
  final Color? color;
  final void Function(double) onRatingUpdate;
  @override
  Widget build(BuildContext context) {
    return RatingBar.builder(
      itemSize: itemSize,
      initialRating: initialRating,
      minRating: minRating,
      direction: Axis.horizontal,
      allowHalfRating: true,
      itemCount: 5,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(Icons.star_rounded, color: color),
      onRatingUpdate: onRatingUpdate,
    );
  }
}
