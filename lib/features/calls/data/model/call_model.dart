// lib/features/calls/data/model/call_model.dart

import 'package:flutter/material.dart';

enum CallType { audio, video }

enum CallStatus { missedIncoming, missedOutgoing, answeredIncoming, answeredOutgoing }

class CallModel {
  final String id;
  final String contactName;
  final String? contactAvatar;
  final CallType callType;
  final CallStatus status;
  final DateTime timestamp;
  final int callCount;

  CallModel({
    required this.id,
    required this.contactName,
    this.contactAvatar,
    required this.callType,
    required this.status,
    required this.timestamp,
    this.callCount = 1,
  });
  CallModel copyWith({
    String? id,
    String? contactName,
    String? contactAvatar,
    CallType? callType,
    CallStatus? status,
    DateTime? timestamp,
    int? callCount,
  }) {
    return CallModel(
      id: id ?? this.id,
      contactName: contactName ?? this.contactName,
      contactAvatar: contactAvatar ?? this.contactAvatar,
      callType: callType ?? this.callType,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      callCount: callCount ?? this.callCount,
    );
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    final hour = timestamp.hour;
    final minute = timestamp.minute.toString().padLeft(2, '0');
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);

    if (difference.inDays == 0) {
      return 'Today, $displayHour:$minute $period';
    } else if (difference.inDays == 1) {
      return 'Yesterday, $displayHour:$minute $period';
    } else {
      return 'July 26, $displayHour:$minute $period';
    }
  }

  bool get isMissed => status == CallStatus.missedIncoming || status == CallStatus.missedOutgoing;
  bool get isIncoming => status == CallStatus.missedIncoming || status == CallStatus.answeredIncoming;

  IconData get directionIcon {
    if (isIncoming) {
      return Icons.call_received;
    } else {
      return Icons.call_made;
    }
  }
}
