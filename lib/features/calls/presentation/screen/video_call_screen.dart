// lib/features/calls/presentation/screens/video_call_screen.dart

import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/custom_elevated_button.dart';
import 'package:lms/core/presentation/widgets/custom_safe_area.dart';
import 'package:lms/features/calls/presentation/widget/build_floating_button.dart';
import 'package:lms/features/calls/presentation/widget/videoCallBottomControlButton.dart';

import '../../data/providers/active_call_provider.dart';

class VideoCallScreen extends ConsumerWidget {
  const VideoCallScreen({super.key});

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
                  textAlign: TextAlign.center,
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
        backgroundColor: Colors.black,
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.kBlue.withAlpha(200),
                AppColors.kBlue.withAlpha(180),
                AppColors.kBlue.withAlpha(50),
              ],
            ),
          ),
          child: Column(
            children: [
              // Top Bar- With Gradient
              Container(
                padding: EdgeInsets.only(
                  top: context.h(3),
                  left: context.w(4),
                  right: context.w(4),
                  bottom: context.h(4),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [AppColors.kBlack.withAlpha(180), AppColors.kTransparent],
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Call Receiver Name
                          Text(
                            callState.call.contactName,
                            style: AppTextStyle.kDisplayTitle.copyWith(color: AppColors.kWhite),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: context.h(0.85)),
                          // Call State
                          Text(
                            callState.phase == ActiveCallPhase.connected
                                ? callState.formattedDuration
                                : 'Calling...',
                            style: AppTextStyle.kBodyLarge.copyWith(color: AppColors.kWhite),
                          ),
                        ],
                      ),
                    ),
                    // Add More People to Call Button
                    Icon(Icons.person_add, color: AppColors.kWhite, size: context.h(4)),
                  ],
                ),
              ),

              //  Middle Section (Main Icon + Right Side Buttons)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Spacing b/w right side button and centered icon
                    SizedBox(width: context.w(10)),

                    // Centered Video Cam Icon
                    Expanded(
                      child: Center(
                        child: Icon(Icons.videocam_off, color: AppColors.kWhite, size: context.h(12)),
                      ),
                    ),

                    // Right Floating Buttons
                    SizedBox(
                      width: context.w(20),
                      child: Column(
                        children: [
                          SizedBox(height: context.h(15)),
                          // Flip Camera Button
                          buildFloatingButton(icon: Icons.flip_camera_android, onTap: () {}, cont: context),
                          SizedBox(height: context.h(2)),
                          // Flash Toggle Button
                          buildFloatingButton(icon: Icons.flash_on, onTap: () {}, cont: context),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom Control Bar
              Container(
                padding: EdgeInsets.symmetric(horizontal: context.w(4), vertical: context.h(2)),
                decoration: BoxDecoration(
                  color: AppColors.kBlack.withAlpha(150),
                  borderRadius: BorderRadius.circular(context.w(8)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // More Button
                    videoCallBottomControlButton(
                      icon: Icons.more_horiz,
                      isActive: false,
                      onTap: () {},
                      context: context,
                    ),
                    // Video Cam Toggle Button
                    videoCallBottomControlButton(
                      icon: callState.isVideoOn ? Icons.videocam : Icons.videocam_off,
                      isActive: callState.isVideoOn,
                      onTap: () => ref.read(activeCallProvider.notifier).toggleVideo(),
                      context: context,
                    ),
                    // Speaker Button
                    videoCallBottomControlButton(
                      icon: callState.isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                      isActive: callState.isSpeakerOn,
                      onTap: () => ref.read(activeCallProvider.notifier).toggleSpeaker(),
                      context: context,
                    ),
                    // Mic Toggle Button
                    videoCallBottomControlButton(
                      icon: callState.isMuted ? Icons.mic_off : Icons.mic,
                      isActive: callState.isMuted,
                      onTap: () => ref.read(activeCallProvider.notifier).toggleMute(),
                      context: context,
                    ),
                    // End Call Button
                    GestureDetector(
                      onTap: () {
                        ref.read(activeCallProvider.notifier).endCall();
                        context.pop();
                      },
                      child: Container(
                        width: context.w(15),
                        height: context.h(7.5),
                        decoration: const BoxDecoration(color: AppColors.kCallEndB, shape: BoxShape.circle),
                        child: Icon(Icons.call_end, color: AppColors.kWhite, size: context.h(4)),
                      ),
                    ),
                  ],
                ),
              ).padOnly(bottom: context.h(5), left: context.w(5), right: context.w(5)),
            ],
          ),
        ),
      ),
    );
  }
}
