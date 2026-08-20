// lib/features/calls/data/services/stream_video_service.dart

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide User, UserInfo;
import 'package:http/http.dart' as http;
import 'package:lms/features/calls/data/model/call_model.dart';
import 'package:stream_video_flutter/stream_video_flutter.dart' as stream;

class StreamVideoService {
  static StreamVideoService? _instance;

  static StreamVideoService get instance => _instance ??= StreamVideoService._();

  StreamVideoService._();

  stream.Call? _currentCall;

  stream.Call? get currentCall => _currentCall;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Local cached media states
  bool _microphoneEnabled = true;
  bool _cameraEnabled = true;

  // --------------------------------------------------
  // CLOUDFLARE WORKER
  // --------------------------------------------------

  static const String _tokenEndpoint = 'https://lms-api.saleemmazhar348.workers.dev/stream-token';


 

  // --------------------------------------------------
  // FETCH STREAM TOKEN
  // --------------------------------------------------

  Future<StreamTokenResponse> _fetchStreamCredentials() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('User must be logged in to fetch Stream credentials');
    }

    // Firebase ID token
    final idToken = await user.getIdToken();

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Failed to obtain Firebase ID token');
    }

    final response = await http.post(
      Uri.parse(_tokenEndpoint),
      headers: {'Authorization': 'Bearer $idToken', 'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to generate Stream token '
        '(HTTP ${response.statusCode}): ${response.body}',
      );
    }

    final body = jsonDecode(response.body);

    if (body['token'] == null) {
      throw Exception('Cloudflare response does not contain a Stream token');
    }

    if (body['apiKey'] == null) {
      throw Exception('Cloudflare response does not contain Stream API key');
    }

    return StreamTokenResponse(
      token: body['token'] as String,
      apiKey: body['apiKey'] as String,
      userId: body['userId'] as String,
    );
  }

  // --------------------------------------------------
  // INITIALIZE STREAM VIDEO
  // --------------------------------------------------

  // We are creating a NEW method that combines Stream + Firestore
  Future<stream.Call> initiateCall({
    required String receiverUid,
    required String receiverName,
    String? receiverAvatar,
    required CallType callType,
  }) async {
    if (!stream.StreamVideo.isInitialized()) {
      throw Exception('StreamVideo client is not initialized');
    }

    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) throw Exception('No authenticated user');

    // 1. Generate a unique Call ID
    final callDocRef = _firestore.collection('calls').doc();
    final callId = callDocRef.id;

    // 2. Start the call on Stream's servers
    final call = stream.StreamVideo.instance.makeCall(
      callType: stream.StreamCallType.defaultType(),
      id: callId,
    );
    await call.getOrCreate();
    await call.join();
    _currentCall = call;

    // 3. Create the CallModel for Firestore
    final callModel = CallModel(
      id: callId,
      callerUid: currentUser.uid,
      receiverUid: receiverUid,
      contactName: receiverName, // The receiver's name from the caller's perspective
      contactAvatar: receiverAvatar,
      callType: callType,
      status: CallStatus.missedOutgoing, // Default state, updated when answered
      timestamp: DateTime.now(),
    );

    // 4. Push to Firestore to trigger signaling for the receiver
    await callDocRef.set(callModel.toFirestore());

    return call;
  }
  Future<void> initStreamVideo({required String uid, required String name, String? avatarUrl}) async {
    // Don't initialize twice
    if (stream.StreamVideo.isInitialized()) {
      return;
    }

    final credentials = await _fetchStreamCredentials();

    // Make sure Firebase UID and Stream UID match
    if (credentials.userId != uid) {
      throw Exception(
        'Authenticated user mismatch. '
        'Firebase UID: $uid, Stream UID: ${credentials.userId}',
      );
    }

    final user = stream.User(
      info: stream.UserInfo(id: uid, name: name, image: avatarUrl),
    );

    stream.StreamVideo(credentials.apiKey, user: user, userToken: credentials.token);
  }

  // --------------------------------------------------
  // CREATE AND JOIN CALL
  // --------------------------------------------------

  Future<stream.Call> makeCall({required String callId, required String callType}) async {
    if (!stream.StreamVideo.isInitialized()) {
      throw Exception('StreamVideo client is not initialized');
    }

    final call = stream.StreamVideo.instance.makeCall(
      callType: stream.StreamCallType.defaultType(),
      id: callId,
    );

    await call.getOrCreate();
    await call.join();

    _currentCall = call;

    return call;
  }

  // --------------------------------------------------
  // JOIN EXISTING CALL
  // --------------------------------------------------

  Future<stream.Call> joinCall(String callId) async {
    if (!stream.StreamVideo.isInitialized()) {
      throw Exception('StreamVideo client is not initialized');
    }

    final call = stream.StreamVideo.instance.makeCall(
      callType: stream.StreamCallType.defaultType(),
      id: callId,
    );

    await call.join();

    _currentCall = call;

    return call;
  }

  // --------------------------------------------------
  // MICROPHONE
  // --------------------------------------------------

  Future<void> toggleMicrophone() async {
    if (_currentCall == null) return;

    _microphoneEnabled = !_microphoneEnabled;

    await _currentCall!.setMicrophoneEnabled(enabled: _microphoneEnabled);
  }

  // --------------------------------------------------
  // CAMERA
  // --------------------------------------------------

  Future<void> toggleCamera() async {
    if (_currentCall == null) return;

    _cameraEnabled = !_cameraEnabled;

    await _currentCall!.setCameraEnabled(enabled: _cameraEnabled);
  }

  // --------------------------------------------------
  // FLIP CAMERA
  // --------------------------------------------------

  Future<void> flipCamera() async {
    if (_currentCall == null) return;

    await _currentCall!.flipCamera();
  }

  // --------------------------------------------------
  // LEAVE CALL
  // --------------------------------------------------

  Future<void> leaveCall() async {
    if (_currentCall != null) {
      await _currentCall!.leave();

      _currentCall = null;

      _microphoneEnabled = true;
      _cameraEnabled = true;
    }
  }

  Future<void> testTokenEndpoint() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('No Firebase user logged in');
    }

    final idToken = await user.getIdToken(true);

    final response = await http.post(
      Uri.parse('https://lms-api.saleemmazhar348.workers.dev/stream-token'),
      headers: {'Authorization': 'Bearer $idToken', 'Content-Type': 'application/json'},
    );

    print('STATUS: ${response.statusCode}');
    print('BODY: ${response.body}');
  }
}

// ======================================================
// STREAM TOKEN RESPONSE
// ======================================================

class StreamTokenResponse {
  final String token;
  final String apiKey;
  final String userId;

  const StreamTokenResponse({required this.token, required this.apiKey, required this.userId});
}
