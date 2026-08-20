import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/core/routing/app_routing.dart';
import 'package:lms/features/calls/data/model/call_model.dart';
import 'package:lms/features/calls/data/providers/active_call_provider.dart';
import 'package:lms/features/calls/data/services/stream_video_service.dart';

class TestWidget extends ConsumerStatefulWidget {
  const TestWidget({super.key});

  @override
  ConsumerState<TestWidget> createState() => _TestWidgetState();
}

class _TestWidgetState extends ConsumerState<TestWidget> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initStream();
  }

  Future<void> _initStream() async {
    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        debugPrint('❌ User is not logged into Firebase');
        return;
      }

      await StreamVideoService.instance.initStreamVideo(uid: user.uid, name: 'Test User');

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      debugPrint('✅ Stream SDK Connected Successfully');
    } catch (e) {
      debugPrint('❌ Stream SDK Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isInitialized
            ? ElevatedButton(
                onPressed: () async {
                  try {
                    debugPrint('⏳ Initiating outgoing call...');
                    final user = FirebaseAuth.instance.currentUser!;
                    final router = ref.read(routerProvider);

                    // 1. Generate a unique call ID
                    final callId = FirebaseFirestore.instance.collection('calls').doc().id;

                    // 2. Create the CallModel for the outgoing call
                    final outgoingCall = CallModel(
                      id: callId,
                      callerUid: user.uid, // You are the caller
                      receiverUid: 'fake_external_user_123', // The person you are calling
                      contactName: 'Jane Smith',
                      callType: CallType.audio,
                      status: CallStatus.missedOutgoing,
                      timestamp: DateTime.now(),
                    );

                    // 3. Save it to Firestore
                    await FirebaseFirestore.instance
                        .collection('calls')
                        .doc(callId)
                        .set(outgoingCall.toFirestore());

                    // 4. Initialize Stream SDK for this call
                    await StreamVideoService.instance.joinCall(callId);

                    // 5. Update State and Navigate
                    ref.read(activeCallProvider.notifier).startCall(outgoingCall);
                    router.push(Routes.audioCall);
                  } catch (e) {
                    debugPrint('❌ Outgoing Call Error: $e');
                  }
                },
                child: const Text('Test Make Call'),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
