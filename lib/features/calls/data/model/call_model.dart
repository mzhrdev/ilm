// lib/features/calls/data/model/call_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

enum CallType { audio, video }

enum CallStatus { missedIncoming, missedOutgoing, answeredIncoming, answeredOutgoing, rejected }

class CallModel {
  final String id;
  final String callerUid;
  final String receiverUid;
  final String contactName;
  final String? contactAvatar;
  final CallType callType;
  final CallStatus status;
  final DateTime timestamp;
  final int durationSeconds;

  CallModel({
    required this.id,
    required this.callerUid,
    required this.receiverUid,
    required this.contactName,
    this.contactAvatar,
    required this.callType,
    required this.status,
    required this.timestamp,
    this.durationSeconds = 0,
  });

  CallModel copyWith({
    String? id,
    String? callerUid,
    String? receiverUid,
    String? contactName,
    String? contactAvatar,
    CallType? callType,
    CallStatus? status,
    DateTime? timestamp,
    int? durationSeconds,
  }) {
    return CallModel(
      id: id ?? this.id,
      callerUid: callerUid ?? this.callerUid,
      receiverUid: receiverUid ?? this.receiverUid,
      contactName: contactName ?? this.contactName,
      contactAvatar: contactAvatar ?? this.contactAvatar,
      callType: callType ?? this.callType,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      durationSeconds: durationSeconds ?? this.durationSeconds,
    );
  }

  // Convert Firestore DocumentSnapshot to CallModel
  factory CallModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc, String currentUserId) {
    final data = doc.data() ?? <String, dynamic>{};
    final isCaller = data['callerUid'] == currentUserId;
    final rawStatus = data['status'] as String? ?? 'missed';

    CallStatus mappedStatus;
    switch (rawStatus) {
      case 'answered':
        mappedStatus = isCaller ? CallStatus.answeredOutgoing : CallStatus.answeredIncoming;
      case 'rejected':
        mappedStatus = CallStatus.rejected;
      case 'missed':
      default:
        mappedStatus = isCaller ? CallStatus.missedOutgoing : CallStatus.missedIncoming;
    }

    final startedAt = data['startedAt'];
    final timestamp = startedAt is Timestamp
        ? startedAt.toDate()
        : startedAt is DateTime
        ? startedAt
        : DateTime.now();

    return CallModel(
      id: doc.id,
      callerUid: data['callerUid'] ?? '',
      receiverUid: data['receiverUid'] ?? '',
      contactName: isCaller ? (data['receiverName'] ?? 'Unknown') : (data['callerName'] ?? 'Unknown'),
      contactAvatar: isCaller ? data['receiverAvatar'] : data['callerAvatar'],
      callType: data['callType'] == 'video' ? CallType.video : CallType.audio,
      status: mappedStatus,
      timestamp: timestamp,
      durationSeconds: (data['durationSeconds'] as num?)?.toInt() ?? 0,
    );
  }

  // Convert CallModel to Map for Firestore persistence
  Map<String, dynamic> toFirestore() {
    return {
      'callerUid': callerUid,
      'receiverUid': receiverUid,
      'callerName': contactName,
      'callerAvatar': contactAvatar,
      'callType': callType.name,
      'status': switch (status) {
        CallStatus.answeredIncoming || CallStatus.answeredOutgoing => 'answered',
        CallStatus.rejected => 'rejected',
        CallStatus.missedIncoming || CallStatus.missedOutgoing => 'missed',
      },
      'startedAt': Timestamp.fromDate(timestamp),
      'durationSeconds': durationSeconds,
    };
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
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}, $displayHour:$minute $period';
    }
  }

  bool get isMissed => status == CallStatus.missedIncoming || status == CallStatus.missedOutgoing;
  bool get isIncoming => status == CallStatus.missedIncoming || status == CallStatus.answeredIncoming;

  IconData get directionIcon {
    return isIncoming ? Icons.call_received : Icons.call_made;
  }
}
