// lib/features/calls/presentation/screens/video_call_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/active_call_provider.dart';

class VideoCallScreen extends ConsumerWidget {
  const VideoCallScreen({super.key});

  // 🟢 MAIN BUILD METHOD: Constructs the entire Video Call screen UI
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the active call state to get current call details (name, duration, mute status, etc.)
    final callState = ref.watch(activeCallProvider);

    // Fallback: If there is no active call state (e.g., call just ended), show a loading spinner
    if (callState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      // We use a Stack to layer different UI elements on top of each other (background, top bar, buttons)
      body: Stack(
        children: [
          // 1️⃣ BACKGROUND: Simulates the camera feed with a gradient and a "camera off" icon
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2C3E50), Color(0xFF34495E), Color(0xFF7F8C8D)],
                ),
              ),
              child: const Center(child: Icon(Icons.videocam_off, color: Colors.white24, size: 100)),
            ),
          ),

          // 2️⃣ TOP BAR: Shows the contact's name, call duration/status, and an "add person" icon
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16, // Accounts for phone notch/status bar
                left: 16,
                right: 16,
                bottom: 16,
              ),
              // Adds a subtle dark gradient at the top so the white text is always readable
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.6), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Displays the name of the person being called
                        Text(
                          callState.call.contactName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        // Shows "Calling..." or the live timer (e.g., "01:23") if connected
                        Text(
                          callState.phase == ActiveCallPhase.connected
                              ? callState.formattedDuration
                              : 'Calling...',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Icon to add another person to the call (placeholder functionality for now)
                  const Icon(Icons.person_add, color: Colors.white, size: 28),
                ],
              ),
            ),
          ),

          // 3️⃣ RIGHT SIDE FLOATING BUTTONS: Quick actions like flip camera or flash
          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.25, // Positions it about 25% down the screen
            child: Column(
              children: [
                _buildFloatingButton(icon: Icons.person_add, onTap: () {}),
                const SizedBox(height: 16),
                _buildFloatingButton(icon: Icons.flip_camera_android, onTap: () {}),
                const SizedBox(height: 16),
                _buildFloatingButton(icon: Icons.flash_on, onTap: () {}),
              ],
            ),
          ),

          // 4️⃣ BOTTOM CONTROL BAR: The main call controls (mute, speaker, video, end call)
          Positioned(
            bottom: 40,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.8), // Semi-transparent background
                borderRadius: BorderRadius.circular(32), // Rounded pill shape
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // More options button
                  _buildBottomControlButton(icon: Icons.more_horiz, isActive: false, onTap: () {}),

                  // Video toggle button (changes icon and color based on isVideoOn state)
                  _buildBottomControlButton(
                    icon: callState.isVideoOn ? Icons.videocam : Icons.videocam_off,
                    isActive: callState.isVideoOn,
                    onTap: () => ref.read(activeCallProvider.notifier).toggleVideo(),
                  ),

                  // Speaker toggle button
                  _buildBottomControlButton(
                    icon: callState.isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                    isActive: callState.isSpeakerOn,
                    onTap: () => ref.read(activeCallProvider.notifier).toggleSpeaker(),
                  ),

                  // Mute toggle button
                  _buildBottomControlButton(
                    icon: callState.isMuted ? Icons.mic_off : Icons.mic,
                    isActive: callState.isMuted,
                    onTap: () => ref.read(activeCallProvider.notifier).toggleMute(),
                  ),

                  // End Call button (Red circle)
                  GestureDetector(
                    onTap: () {
                      // 1. End the call and update the provider state (saves to history)
                      ref.read(activeCallProvider.notifier).endCall();

                      // 2. Navigate back to the previous screen (Chat/Messages screen)
                      context.pop();
                    },
                    child: Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(color: Color(0xFFE91E63), shape: BoxShape.circle),
                      child: const Icon(Icons.call_end, color: Colors.white, size: 28),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 🟡 HELPER FUNCTION 1: Builds the circular floating buttons on the right side of the screen.
  // It takes an icon and an onTap action, and styles them with a semi-transparent black background.
  Widget _buildFloatingButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

  // 🟡 HELPER FUNCTION 2: Builds the circular control buttons at the bottom of the screen.
  // It changes its background and icon color based on the `isActive` state.
  // Example: White background + black icon when muted/speaker is ON.
  // Transparent background + white icon when OFF.
  Widget _buildBottomControlButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isActive ? Colors.black : Colors.white, size: 24),
      ),
    );
  }
}
