// lib/features/calls/presentation/screens/audio_call_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/providers/active_call_provider.dart';

class AudioCallScreen extends ConsumerWidget {
  const AudioCallScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final callState = ref.watch(activeCallProvider);

    if (callState == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1419),
      body: Stack(
        children: [
          Positioned.fill(
            child: Opacity(opacity: 0.05, child: CustomPaint(painter: PatternPainter())),
          ),

          Column(
            children: [
              const SizedBox(height: 60),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 28),
                      onPressed: () {
                        ref.read(activeCallProvider.notifier).endCall();
                        context.pop();
                      },
                    ),
                    const Icon(Icons.person_add, color: Colors.white, size: 28),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              Text(
                callState.call.contactName,
                style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 8),

              Text(
                callState.phase == ActiveCallPhase.connected ? callState.formattedDuration : 'Calling...',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 16),
              ),

              const Spacer(),

              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2), width: 3),
                ),
                child: ClipOval(
                  child: callState.call.contactAvatar != null
                      ? Image.network(
                          callState.call.contactAvatar!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Icon(Icons.person, size: 100, color: Colors.white),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[800],
                          child: const Icon(Icons.person, size: 100, color: Colors.white),
                        ),
                ),
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildControlButton(
                          icon: callState.isSpeakerOn ? Icons.volume_up : Icons.volume_off,
                          label: 'Speaker',
                          isActive: callState.isSpeakerOn,
                          onTap: () => ref.read(activeCallProvider.notifier).toggleSpeaker(),
                        ),
                        _buildControlButton(
                          icon: Icons.videocam,
                          label: 'Video',
                          isActive: false,
                          onTap: () {},
                        ),
                        _buildControlButton(
                          icon: callState.isMuted ? Icons.mic_off : Icons.mic,
                          label: 'Mute',
                          isActive: callState.isMuted,
                          onTap: () => ref.read(activeCallProvider.notifier).toggleMute(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildControlButton(
                          icon: Icons.more_horiz,
                          label: 'More',
                          isActive: false,
                          onTap: () {},
                        ),
                        _buildControlButton(
                          icon: Icons.upload,
                          label: 'Share',
                          isActive: false,
                          onTap: () {},
                        ),
                        GestureDetector(
                          onTap: () {
                            ref.read(activeCallProvider.notifier).endCall();
                            context.pop();
                          },
                          child: Column(
                            children: [
                              Container(
                                width: 64,
                                height: 64,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE91E63),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.call_end, color: Colors.white, size: 32),
                              ),
                              const SizedBox(height: 8),
                              const Text('End', style: TextStyle(color: Colors.white, fontSize: 14)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: isActive ? Colors.black : Colors.white, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        ],
      ),
    );
  }
}

class PatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < 20; i++) {
      canvas.drawCircle(Offset(size.width * 0.1 * i, size.height * 0.1 * (i % 10)), 20, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
