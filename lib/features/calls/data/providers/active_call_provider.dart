// lib/features/calls/data/provider/active_call_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/call_model.dart';

enum ActiveCallPhase { dialing, ringing, connected, ended }

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

final activeCallProvider = StateNotifierProvider<ActiveCallNotifier, ActiveCallState?>((ref) {
  return ActiveCallNotifier();
});

class ActiveCallNotifier extends StateNotifier<ActiveCallState?> {
  ActiveCallNotifier() : super(null);

  Timer? _timer;

  void startCall(CallModel call) {
    state = ActiveCallState(
      call: call,
      phase: ActiveCallPhase.dialing,
    );

    Future.delayed(const Duration(seconds: 3), () {
      if (state != null && state!.phase == ActiveCallPhase.dialing) {
        connectCall();
      }
    });
  }

  void connectCall() {
    if (state == null) return;
    
    state = state!.copyWith(phase: ActiveCallPhase.connected);
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state != null && state!.phase == ActiveCallPhase.connected) {
        state = state!.copyWith(
          callDuration: state!.callDuration + const Duration(seconds: 1),
        );
      }
    });
  }

  void endCall() {
    _timer?.cancel();
    
    if (state != null) {
      final updatedCall = state!.call.copyWith(
        status: state!.callDuration.inSeconds > 0 
            ? (state!.call.isIncoming ? CallStatus.answeredIncoming : CallStatus.answeredOutgoing)
            : (state!.call.isIncoming ? CallStatus.missedIncoming : CallStatus.missedOutgoing),
        timestamp: DateTime.now(),
      );

      state = state!.copyWith(
        call: updatedCall,
        phase: ActiveCallPhase.ended,
      );
    }
    
    Future.delayed(const Duration(milliseconds: 800), () {
      state = null;
    });
  }

  void toggleMute() {
    if (state != null) {
      state = state!.copyWith(isMuted: !state!.isMuted);
    }
  }

  void toggleSpeaker() {
    if (state != null) {
      state = state!.copyWith(isSpeakerOn: !state!.isSpeakerOn);
    }
  }

  void toggleVideo() {
    if (state != null) {
      state = state!.copyWith(isVideoOn: !state!.isVideoOn);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}