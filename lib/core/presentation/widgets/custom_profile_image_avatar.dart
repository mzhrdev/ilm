
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:Edvance/core/constants/app_colors.dart';



class CustomProfileImageAvatar extends StatelessWidget {
  const CustomProfileImageAvatar({
    super.key,
    this.onTap,
    this.inkWellEffectBorderRadius = 30,
   
    this.maximumCircleAvatarRadius = 23,

    this.circleAvatarBackgroundColor = AppColors.kPrimary,
    required this.profileImageUrl,
    this.imageCircleAvatarRadius = 21,
    this.badgeSize = 10,
    this.badgeColor,
    this.badgeVisible = false,
    this.paddingAroundParentCircleAvatar = 5,
    this.badgeVerticalAlignment = 0.6,
    this.badgeHorizontalAlignment = 0.7,
  });
  final void Function()? onTap;
  final double? maximumCircleAvatarRadius;
  final double paddingAroundParentCircleAvatar;
  final double inkWellEffectBorderRadius;
  final Color? circleAvatarBackgroundColor;
  final double? imageCircleAvatarRadius;
  final String profileImageUrl;
  final double? badgeSize;
  final Color? badgeColor;
  final bool? badgeVisible;
  final double badgeVerticalAlignment;
  final double badgeHorizontalAlignment;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(inkWellEffectBorderRadius),
      child: Badge(
        alignment: Alignment(
          //Badge Horizontal Alignment
          badgeHorizontalAlignment,
          //Badge Vertical Alignment
          badgeVerticalAlignment,
        ),
        //Badge Color
        backgroundColor: badgeColor,
        //Badge Visibility
        isLabelVisible: badgeVisible!,
        //Badge Size
        smallSize: badgeSize,
        child: CircleAvatar(
          //Maximum Parent Circle Avatar Radius
          radius: maximumCircleAvatarRadius,
          //Parent Circle Avatar Background Color
          backgroundColor: circleAvatarBackgroundColor,
          child: CachedNetworkImage(
            imageUrl:
                //Profile Image Link
                profileImageUrl,
            imageBuilder: (
              context,
              imageProvider,
            ) =>
                CircleAvatar(
              //Image Circle Avatar Radius
              radius: imageCircleAvatarRadius,
              backgroundImage: imageProvider,
            ),
            placeholder: (
              context,
              url,
            ) =>
                const CircularProgressIndicator(),
            errorWidget: (
              context,
              url,
              error,
            ) =>
                const Icon(
              Icons.error,
            ),
          ),
        ).padAll(
            //Padding Around Parent Circle Avatar For Ink Well Effect
            paddingAroundParentCircleAvatar),
      ),
    );
  }
}
