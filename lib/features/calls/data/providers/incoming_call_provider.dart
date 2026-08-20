import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/auth/data/providers/auth_provider.dart';

import '../model/call_model.dart';

final incomingCallStreamProvider = StreamProvider<CallModel?>((ref) {
  // 1. Watch your existing convenience provider.
  // This automatically rebuilds the stream whenever the user logs in or out.
  final currentUser = ref.watch(currentUserProvider);

  if (currentUser == null) {
    debugPrint('📡 Stream: No authenticated user found.');
    return Stream.value(null);
  }

  debugPrint('📡 Stream: Connected for UID ${currentUser.id}. Listening to Firestore...');

  // 2. Listen to Firestore using currentUser.id
  // We keep the local sorting logic to bypass the composite index requirement.
  return FirebaseFirestore.instance
      .collection('calls')
      .where('receiverUid', isEqualTo: currentUser.id)
      .snapshots()
      .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return null;
        }

        // 3. Map documents to CallModels and apply our local filters
        final calls =
            snapshot.docs
                .map((doc) => CallModel.fromFirestore(doc, currentUser.id))
                .where((call) => call.isIncoming && call.status == CallStatus.missedIncoming)
                .toList()
              ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

        if (calls.isEmpty) return null;

        final activeCall = calls.first;
        debugPrint('🔔 SUCCESS: Provider yielding active call for ${activeCall.contactName}');
        return activeCall;
      });
});
