import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/calls/data/model/call_model.dart';
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
                    debugPrint('⏳ Injecting fake incoming call...');

                    final user = FirebaseAuth.instance.currentUser!;

                    // Directly write to Firestore simulating SOMEONE ELSE calling you
                    await FirebaseFirestore.instance.collection('calls').doc('test-call-123').set({
                      'callerUid': 'fake_external_user_123', // Someone else's UID
                      'receiverUid': user.uid, // You are the receiver
                      'callerName': 'John Doe', // The fake caller's name
                      'callType': 'audio',
                      'status': 'missed',
                      'startedAt': FieldValue.serverTimestamp(),
                      'durationSeconds': 0,
                    });

                    debugPrint('✅ Fake incoming call injected!');
                  } catch (e) {
                    debugPrint('❌ Fake Call Error: $e');
                  }
                },
                child: const Text('Test Make Call'),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
