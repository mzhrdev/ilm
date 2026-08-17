import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lms/core/constants/app_colors.dart';

class CustomCachedNetworkImage extends StatelessWidget {
  const CustomCachedNetworkImage({
    super.key,
    required this.height,
    required this.width,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.topLeftRadiusCircular = 0,
    this.topRightRadiusCircular = 0,
    this.bottomLeftRadiusCircular = 0,
    this.bottomRightRadiusCircular = 0,
    this.progressIndicatorColor = AppColors.kPrimary,
    this.child,
    this.radius,
    this.border,
  });
  final double? height;
  final double? width;
  final String imageUrl;
  final BoxFit? fit;
  final double topLeftRadiusCircular;
  final double topRightRadiusCircular;
  final double bottomLeftRadiusCircular;
  final double bottomRightRadiusCircular;
  final Color? progressIndicatorColor;
  final double? radius;
  final Widget? child;
  final BoxBorder? border;
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      height: height,
      width: width,
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) {
        return Container(
          decoration: BoxDecoration(
            borderRadius: radius != null
                ? BorderRadius.circular(radius!)
                : BorderRadius.only(
                    topLeft: Radius.circular(topLeftRadiusCircular),
                    topRight: Radius.circular(topRightRadiusCircular),
                    bottomLeft: Radius.circular(bottomLeftRadiusCircular),
                    bottomRight: Radius.circular(bottomRightRadiusCircular),
                  ),
            border: border,
            image: DecorationImage(image: imageProvider, fit: fit),
          ),
          child: child,
        );
      },
      errorWidget: (context, url, error) => const Icon(Icons.error, color: AppColors.kRed),
      progressIndicatorBuilder: (context, url, progress) => Center(
        child: CircularProgressIndicator(
          value: progress.progress,
          strokeCap: StrokeCap.round,
          color: progressIndicatorColor,
        ),
      ),
    );
  }
}
