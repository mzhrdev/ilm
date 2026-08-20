import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
                    debugPrint('⏳ Attempting to create a call...');
                    // Generating a dummy call ID for this test
                    final call = await StreamVideoService.instance.makeCall(
                      callId: 'test-call-123',
                      callType: 'audio',
                    );
                    debugPrint('✅ Call Created and Joined successfully. ID: ${call.id}');
                  } catch (e) {
                    debugPrint('❌ Call Creation Error: $e');
                  }
                },
                child: const Text('Test Make Call'),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
