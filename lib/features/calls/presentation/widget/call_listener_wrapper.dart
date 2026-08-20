import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/calls/data/providers/active_call_provider.dart';
import 'package:lms/features/calls/data/providers/incoming_call_provider.dart';
import 'package:lms/features/calls/data/services/stream_video_service.dart';

import '../../data/model/call_model.dart';

class CallListenerWrapper extends ConsumerWidget {
  final Widget child;

  const CallListenerWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Watch the stream that listens for incoming calls in Firestore
    final incomingCallAsync = ref.watch(incomingCallStreamProvider);
    final incomingCall = incomingCallAsync.valueOrNull;
    // 👉 ADD THIS TO EXPOSE THE SILENT ERROR:
    if (incomingCallAsync.hasError) {
      debugPrint('🚨 FIRESTORE STREAM ERROR: ${incomingCallAsync.error}');
    }
    // 👉 ADD THIS PRINT:
    debugPrint('📱 WRAPPER UI REBUILDING. Current call state: ${incomingCall?.contactName ?? "NULL"}');
    return Stack(
      textDirection: TextDirection.ltr,
      children: [
        // The rest of your application UI
        child,

        // 2. The UI Overlay: Only shows up when an incoming call is active
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
                          // Update Firestore status to rejected
                          await FirebaseFirestore.instance.collection('calls').doc(incomingCall.id).update({
                            'status': 'rejected',
                          });
                        },
                        child: const Icon(Icons.call_end, color: Colors.white),
                      ),

                      // Accept Button
                      FloatingActionButton(
                        heroTag: 'accept_call_btn',
                        backgroundColor: Colors.green,
                        onPressed: () async {
                          try {
                            // 1. Update Firestore status to answered
                            await FirebaseFirestore.instance.collection('calls').doc(incomingCall.id).update({
                              'status': 'answered',
                            });

                            // 2. Join the Stream call using the call ID
                            await StreamVideoService.instance.joinCall(incomingCall.id);

                            // 3. Set active call state in provider
                            ref.read(activeCallProvider.notifier).startCall(incomingCall);
                            ref.read(activeCallProvider.notifier).connectCall();

                            // 4. NAVIGATE TO CALL SCREEN FIX:
                            // Use Riverpod to grab the GoRouter instance globally instead of context.push
                            final router = ref.read(routerProvider);
                            if (incomingCall.callType == CallType.video) {
                              router.push(Routes.videoCall);
                            } else {
                              router.push(Routes.audioCall);
                            }
                          } catch (e) {
                            debugPrint('❌ Error accepting call: $e');
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
