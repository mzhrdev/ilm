// lib/features/calls/data/dummy_data/mock_calls.dart

import 'package:lms/features/calls/data/model/call_model.dart';

final List<CallModel> mockCalls = [
  CallModel(
    id: '1',
    callerUid: 'user_saleem',
    receiverUid: 'current_user_id',
    contactName: 'Saleem Akhtar',
    callType: CallType.audio,
    status: CallStatus.missedIncoming,
    timestamp: DateTime.now().subtract(const Duration(hours: 4)),
  ),
  CallModel(
    id: '2',
    callerUid: 'user_ali',
    receiverUid: 'current_user_id',
    contactName: 'Ali G',
    callType: CallType.audio,
    status: CallStatus.missedIncoming,
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
  ),
  CallModel(
    id: '3',
    callerUid: 'user_kakar',
    receiverUid: 'current_user_id',
    contactName: 'Kakar & Azib',
    callType: CallType.video,
    status: CallStatus.answeredIncoming,
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4, minutes: 30)),
    durationSeconds: 120,
  ),
  CallModel(
    id: '4',
    callerUid: 'current_user_id',
    receiverUid: 'user_azib',
    contactName: 'Azib Ali Burraq',
    callType: CallType.audio,
    status: CallStatus.answeredOutgoing,
    timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
    durationSeconds: 45,
  ),
];
