// lib/features/calls/presentation/screens/audio_call_screen.dart

import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/custom_elevated_button.dart';
import 'package:lms/core/presentation/widgets/custom_icon_button.dart';
import 'package:lms/core/presentation/widgets/custom_safe_area.dart';
import 'package:lms/features/calls/presentation/widget/audioCallControlButton.dart';

import '../../data/providers/active_call_provider.dart';

class AudioCallScreen extends ConsumerWidget {
  const AudioCallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(activeCallProvider);

    // On Call Error UI
    if (callState == null) {
      return CustomSafeArea(
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Error Icon
              Icon(Icons.error_outline, color: AppColors.kRed, size: context.h(10)).padBottom(context.h(3)),
              // Error Message
              Center(
                child: Text(
                  " Error placing call! \n Retry or Navigate \n to Conversation Screen",
                  style: AppTextStyle.kBodyLarge.copyWith(color: AppColors.kBlack),
                ),
              ).padBottom(context.h(3)),
              // Retry Button
              CustomElevatedButton(
                buttonColor: AppColors.kSecondary,
                title: "Retry",
                onPress: () {
                  //TODO: Implement the Retry Logic here
                },
                bWidth: context.w(70),
              ).padBottom(context.h(3)),
              // Screen pop Button
              CustomElevatedButton(
                buttonColor: AppColors.kGreen,
                title: "Navigate Back",
                onPress: () => context.pop(),
                bWidth: context.w(70),
              ),
            ],
          ),
        ),
      );
    }

    return CustomSafeArea(
      child: Scaffold(
        backgroundColor: AppColors.kBlack.withAlpha(170),
        body: Column(
          children: [
            // Padding from top
            SizedBox(height: context.h(1)),
            // Add Person to Call Button
            CustomIconButton(
              icon: Icons.person_add,
              onTap: () {
                //TODO: Implement Group Call Functionality
              },
              iconSize: context.h(4),
            ).topRightAlign,
            SizedBox(height: context.h(2.5)),
            // Call Receiver Name
            Text(
              callState.call.contactName,
              style: AppTextStyle.kDisplayTitle.copyWith(fontSize: context.h(3), color: AppColors.kWhite),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.h(1.5)),
            // Call State (Calling, Ringing, Call Minutes Count)
            Text(
              callState.phase == ActiveCallPhase.connected ? callState.formattedDuration : 'Calling...',
              style: AppTextStyle.kBodyLarge.copyWith(color: AppColors.kWhite),
            ),
            const Spacer(),
            // Call Receiver Profile Image
            SizedBox(
              height: context.h(25),
              width: context.w(55),
              child: ClipOval(
                child: callState.call.contactAvatar != null
                    ? Image.network(
                        callState.call.contactAvatar!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: AppColors.kBlack.withAlpha(150),
                            child: Icon(Icons.person, size: context.h(13), color: AppColors.kWhite),
                          );
                        },
                      )
                    : Container(
                        color: AppColors.kBlack.withAlpha(150),
                        child: Icon(Icons.person, size: context.h(13), color: AppColors.kWhite),
                      ),
              ),
            ),
            const Spacer(),
            // Box of Buttons for Actions
            Container(
              decoration: BoxDecoration(
                color: AppColors.kBlack.withAlpha(150),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                  bottomLeft: Radius.circular(32),
                  bottomRight: Radius.circular(32),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // Speaker Button
                      audioCallControlButton(
                        icon: callState.isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                        label: 'Speaker',
                        isActive: callState.isSpeakerOn,
                        onTap: () => ref.read(activeCallProvider.notifier).toggleSpeaker(),
                        context: context,
                      ),
                      // Video Button
                      audioCallControlButton(
                        icon: Icons.videocam,
                        label: 'Video',
                        isActive: false,
                        onTap: () {},
                        context: context,
                      ),
                      // Mute Button
                      audioCallControlButton(
                        icon: callState.isMuted ? Icons.mic_off : Icons.mic,
                        label: 'Mute',
                        isActive: callState.isMuted,
                        onTap: () => ref.read(activeCallProvider.notifier).toggleMute(),
                        context: context,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // More... Button
                      audioCallControlButton(
                        icon: Icons.more_horiz,
                        label: 'More',
                        isActive: false,
                        onTap: () {},
                        context: context,
                      ),
                      // Share Button
                      audioCallControlButton(
                        icon: Icons.upload,
                        label: 'Share',
                        isActive: false,
                        onTap: () {},
                        context: context,
                      ),
                      // End Call Button
                      GestureDetector(
                        onTap: () {
                          ref.read(activeCallProvider.notifier).endCall();
                          context.pop();
                        },
                        child: Column(
                          children: [
                            Container(
                              width: context.w(19),
                              height: context.h(8),
                              decoration: BoxDecoration(color: AppColors.kCallEndB, shape: BoxShape.circle),
                              child: Icon(Icons.call_end, color: AppColors.kWhite, size: context.h(4)),
                            ),
                            SizedBox(height: context.h(1)),
                            Text('End', style: AppTextStyle.kBodyMedium.copyWith(color: AppColors.kWhite)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ).padAll(context.h(2)),
            ).padOnly(bottom: context.h(5), left: context.w(6), right: context.w(6)),
          ],
        ),
      ),
    );
  }
}
