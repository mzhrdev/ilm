import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/calls/data/model/call_model.dart';
import 'package:lms/features/calls/data/providers/active_call_provider.dart';
import 'package:lms/features/calls/data/providers/incoming_call_provider.dart';
import 'package:lms/features/calls/data/services/call_audio_service.dart';
import 'package:lms/features/calls/data/services/stream_video_service.dart';

class CallListenerWrapper extends ConsumerWidget {
  final Widget child;

  const CallListenerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final incomingCallAsync = ref.watch(incomingCallStreamProvider);
    final incomingCall = incomingCallAsync.valueOrNull;

    // Trigger or stop incoming ringtone based on call presence
    if (incomingCall != null) {
      CallAudioService.instance.startRingtone();
    } else {
      CallAudioService.instance.stop();
    }

    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        child,

        if (incomingCall != null)
          Positioned.fill(
            child: Material(
              color: Colors.black.withValues(alpha: 0.9),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.ring_volume, color: Colors.white, size: 64),
                  const SizedBox(height: 24),
                  Text(
                    incomingCall.contactName,
                    style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Incoming ${incomingCall.callType == CallType.video ? 'Video' : 'Audio'} Call',
                    style: const TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                  const SizedBox(height: 64),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // REJECT BUTTON
                      FloatingActionButton(
                        heroTag: 'reject_call_btn',
                        backgroundColor: Colors.red,
                        onPressed: () async {
                          // Stop sound immediately on user interaction
                          CallAudioService.instance.stop();

                          await FirebaseFirestore.instance.collection('calls').doc(incomingCall.id).update({
                            'status': 'rejected',
                          });
                        },
                        child: const Icon(Icons.call_end, color: Colors.white),
                      ),

                      // ACCEPT BUTTON
                      FloatingActionButton(
                        heroTag: 'accept_call_btn',
                        backgroundColor: Colors.green,
                        onPressed: () async {
                          // Stop sound immediately on user interaction
                          CallAudioService.instance.stop();

                          try {
                            await FirebaseFirestore.instance.collection('calls').doc(incomingCall.id).update({
                              'status': 'answered',
                            });

                            await StreamVideoService.instance.joinCall(incomingCall.id);

                            ref.read(activeCallProvider.notifier).startCall(incomingCall);
                            ref.read(activeCallProvider.notifier).connectCall();

                            final router = ref.read(routerProvider);
                            if (incomingCall.callType == CallType.video) {
                              router.push(Routes.videoCall);
                            } else {
                              router.push(Routes.audioCall);
                            }
                          } catch (e) {
                            debugPrint('Error accepting call: $e');
                          }
                        },
                        child: const Icon(Icons.call, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
