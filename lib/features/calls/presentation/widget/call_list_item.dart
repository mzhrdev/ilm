import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/snackbar.dart';
import 'package:lms/features/auth/data/providers/current_user_provider.dart';
import 'package:lms/features/calls/data/model/call_model.dart';
import 'package:lms/features/calls/data/services/stream_video_service.dart';

class CallListItem extends ConsumerWidget {
  final CallModel call;
  final VoidCallback onCallBack;

  const CallListItem({super.key, required this.call, required this.onCallBack});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Profile Image
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(context.w(5)),
        border: Border.all(color: AppColors.kGrey, width: context.w(0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: context.w(13),
            height: context.h(6),
            decoration: BoxDecoration(color: AppColors.kGrey, shape: BoxShape.circle),
            child: call.contactAvatar != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: Image.network(
                      call.contactAvatar!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.person, color: AppColors.kBlack.withAlpha(150), size: context.w(9));
                      },
                    ),
                  )
                : Icon(Icons.person, color: AppColors.kBlack.withAlpha(150), size: context.w(9)),
          ),
          SizedBox(width: context.w(3)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Contact Name
                Text(
                  call.contactName,
                  style: AppTextStyle.kSectionTitle.copyWith(
                    color: call.isMissed ? AppColors.kCallEndB : AppColors.kBlack,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: context.h(0.5)),
                Row(
                  children: [
                    // Call Direction Icon
                    Icon(
                      call.directionIcon,
                      size: context.h(1.5),
                      color: call.isMissed ? AppColors.kCallEndB : AppColors.kGreen,
                    ),
                    SizedBox(width: context.w(1)),
                    // Formatted Time - e.g; Today, 2:19 PM
                    Text(
                      call.formattedTime,
                      style: AppTextStyle.kBodyMedium.copyWith(
                        fontSize: context.h(1.5),
                        color: AppColors.kBlack.withAlpha(100),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Call Button (Audio or Video)
          GestureDetector(
            onTap: () async {
              final currentUser = ref.read(currentUserProvider);
              final currentUserId = currentUser?.id ?? '';
              // Identify the target recipient UID (the opposite party in the call model)
              final targetUid = call.callerUid == currentUserId ? call.receiverUid : call.callerUid;
              try {
                await StreamVideoService.instance.initiateAudioCall(
                  ref: ref,
                  receiverUid: targetUid,
                  receiverName: call.contactName,
                  receiverAvatar: call.contactAvatar,
                );
              } catch (e) {
                // ignore: use_build_context_synchronously
                ShowSnackbar1.error(context, 'Failed to place call: $e');
              }
            },
            // Actual Button
            child: Container(
              width: context.w(11),
              height: context.h(5),
              decoration: BoxDecoration(color: AppColors.kGrey, shape: BoxShape.circle),
              child: Icon(
                call.callType == CallType.video ? Icons.videocam : Icons.call,
                color: AppColors.kBlack,
                size: context.h(3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
