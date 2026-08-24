// lib/features/calls/data/services/call_firestore_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:lms/features/calls/data/model/call_model.dart';

class CallFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection reference for call history
  CollectionReference<Map<String, dynamic>> get _callsRef => _firestore.collection('calls');

  /// Saves a completed or missed call entry to Firestore
  Future<void> logCall(CallModel call) async {
    try {
      await _callsRef.doc(call.id).set(call.toFirestore());
    } catch (e) {
      rethrow;
    }
  }

  /// Streams call history records where currentUserId is caller or receiver
  Stream<List<CallModel>> getCallHistoryStream(String currentUserId) {
    return _callsRef
        .where(
          Filter.or(
            Filter('callerUid', isEqualTo: currentUserId),
            Filter('receiverUid', isEqualTo: currentUserId),
          ),
        )
        .snapshots()
        .map((snapshot) {
          final calls = snapshot.docs.map((doc) => CallModel.fromFirestore(doc, currentUserId)).toList();
          calls.sort((a, b) => b.timestamp.compareTo(a.timestamp));
          return calls;
        });
  }
}
