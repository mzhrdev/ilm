import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/calls/data/services/call_audio_service.dart';
import 'package:lms/features/calls/data/services/stream_video_service.dart';

import '../model/call_model.dart';

enum ActiveCallPhase { dialing, ringing, connected, ended }

final activeCallProvider = StateNotifierProvider<ActiveCallNotifier, ActiveCallState?>((ref) {
  return ActiveCallNotifier();
});

class ActiveCallState {
  final CallModel call;
  final ActiveCallPhase phase;
  final Duration callDuration;
  final bool isMuted;
  final bool isSpeakerOn;
  final bool isVideoOn;

  ActiveCallState({
    required this.call,
    this.phase = ActiveCallPhase.dialing,
    this.callDuration = Duration.zero,
    this.isMuted = false,
    this.isSpeakerOn = false,
    this.isVideoOn = false,
  });

  ActiveCallState copyWith({
    CallModel? call,
    ActiveCallPhase? phase,
    Duration? callDuration,
    bool? isMuted,
    bool? isSpeakerOn,
    bool? isVideoOn,
  }) {
    return ActiveCallState(
      call: call ?? this.call,
      phase: phase ?? this.phase,
      callDuration: callDuration ?? this.callDuration,
      isMuted: isMuted ?? this.isMuted,
      isSpeakerOn: isSpeakerOn ?? this.isSpeakerOn,
      isVideoOn: isVideoOn ?? this.isVideoOn,
    );
  }

  String get formattedDuration {
    final minutes = callDuration.inMinutes.toString().padLeft(2, '0');
    final seconds = (callDuration.inSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}

class ActiveCallNotifier extends StateNotifier<ActiveCallState?> {
  ActiveCallNotifier() : super(null);

  Timer? _timer;
  StreamSubscription<DocumentSnapshot>? _outgoingCallSub;

  // startVoiceCall method
  void startCall(CallModel call) {
    state = ActiveCallState(call: call, phase: ActiveCallPhase.dialing);

    // If it's an outgoing call, listen to Firestore for the receiver's response
    if (!call.isIncoming) {
      _outgoingCallSub?.cancel();
      _outgoingCallSub = FirebaseFirestore.instance.collection('calls').doc(call.id).snapshots().listen((
        snapshot,
      ) {
        if (!snapshot.exists) return;

        final status = snapshot.data()?['status'] as String?;

        if (status == 'answered') {
          connectCall(); // They picked up! Start the timer.
          _outgoingCallSub?.cancel();
        } else if (status == 'rejected') {
          endCall(); // They declined! Hang up.
        }
      });
    }
  }

  // Answer To Incoming Call
  void connectCall() {
    if (state == null) return;

    state = state!.copyWith(phase: ActiveCallPhase.connected);

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state != null && state!.phase == ActiveCallPhase.connected) {
        state = state!.copyWith(callDuration: state!.callDuration + const Duration(seconds: 1));
      }
    });
  }

  // Ending Voice Call Method
  Future<void> endCall() async {
    _timer?.cancel();
    // Stop any active dial or ring tones immediately
    CallAudioService.instance.stop();

    if (state != null) {
      // 1. Tell Stream SDK to disconnect the WebRTC connection
      await StreamVideoService.instance.leaveCall();

      final updatedCall = state!.call.copyWith(
        status: state!.callDuration.inSeconds > 0
            ? (state!.call.isIncoming ? CallStatus.answeredIncoming : CallStatus.answeredOutgoing)
            : (state!.call.isIncoming ? CallStatus.missedIncoming : CallStatus.missedOutgoing),
        timestamp: DateTime.now(),
        durationSeconds: state!.callDuration.inSeconds,
      );

      // 2. Update Firestore so the call history reflects the final duration
      await FirebaseFirestore.instance.collection('calls').doc(updatedCall.id).update({
        'status':
            updatedCall.status == CallStatus.answeredIncoming ||
                updatedCall.status == CallStatus.answeredOutgoing
            ? 'answered'
            : 'missed',
        'durationSeconds': updatedCall.durationSeconds,
      });

      state = state!.copyWith(call: updatedCall, phase: ActiveCallPhase.ended);
    }

    Future.delayed(const Duration(milliseconds: 800), () {
      state = null;
    });
  }

  // Toggle Microphone Method
  Future<void> toggleMute() async {
    if (state != null) {
      // Hardware Action: Mute the microphone via Stream SDK
      await StreamVideoService.instance.toggleMicrophone();
      // UI Action: Update the icon
      state = state!.copyWith(isMuted: !state!.isMuted);
    }
  }

  // Toggle Speaker Method
  Future<void> toggleSpeaker() async {
    if (state != null) {
      // (Stream SDK handles audio routing natively, but we update the UI state here)
      state = state!.copyWith(isSpeakerOn: !state!.isSpeakerOn);
    }
  }

  // Toggle Video Method
  Future<void> toggleVideo() async {
    if (state != null) {
      // Hardware Action: Turn on/off camera
      await StreamVideoService.instance.toggleCamera();
      // UI Action: Update the icon
      state = state!.copyWith(isVideoOn: !state!.isVideoOn);
    }
  }


  // Dispose Method
  @override
  void dispose() {
    _timer?.cancel();
    _outgoingCallSub?.cancel();
    super.dispose();
  }
}
