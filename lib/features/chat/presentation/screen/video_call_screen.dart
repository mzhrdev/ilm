// lib/features/calls/presentation/screens/video_call_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/provider/active_call_provider.dart';

class VideoCallScreen extends ConsumerWidget {
  const VideoCallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(activeCallProvider);

    if (callState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
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

          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                bottom: 16,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        Text(
                          callState.phase == ActiveCallPhase.connected
                              ? callState.formattedDuration
                              : 'Calling...',
                          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Icon(Icons.person_add, color: Colors.white, size: 28),
                ],
              ),
            ),
          ),

          Positioned(
            right: 16,
            top: MediaQuery.of(context).size.height * 0.25,
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

          Positioned(
            bottom: 40,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(32),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildBottomControlButton(icon: Icons.more_horiz, isActive: false, onTap: () {}),
                  _buildBottomControlButton(
                    icon: callState.isVideoOn ? Icons.videocam : Icons.videocam_off,
                    isActive: callState.isVideoOn,
                    onTap: () => ref.read(activeCallProvider.notifier).toggleVideo(),
                  ),
                  _buildBottomControlButton(
                    icon: callState.isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                    isActive: callState.isSpeakerOn,
                    onTap: () => ref.read(activeCallProvider.notifier).toggleSpeaker(),
                  ),
                  _buildBottomControlButton(
                    icon: callState.isMuted ? Icons.mic_off : Icons.mic,
                    isActive: callState.isMuted,
                    onTap: () => ref.read(activeCallProvider.notifier).toggleMute(),
                  ),
                  GestureDetector(
                    onTap: () => ref.read(activeCallProvider.notifier).endCall(),
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

  Widget _buildFloatingButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), shape: BoxShape.circle),
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }

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
          color: isActive ? Colors.white : Colors.white.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isActive ? Colors.black : Colors.white, size: 24),
      ),
    );
  }
}
