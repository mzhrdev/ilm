// lib/features/calls/data/provider/calls_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/call_model.dart';

final callsProvider = StateNotifierProvider<CallsNotifier, CallsState>((ref) {
  return CallsNotifier();
});

class CallsState {
  final List<CallModel> calls;
  final bool isLoading;
  final String searchQuery;

  CallsState({required this.calls, this.isLoading = false, this.searchQuery = ''});

  List<CallModel> get filteredCalls {
    if (searchQuery.isEmpty) {
      return calls;
    }
    return calls.where((call) => call.contactName.toLowerCase().contains(searchQuery.toLowerCase())).toList();
  }

  CallsState copyWith({List<CallModel>? calls, bool? isLoading, String? searchQuery}) {
    return CallsState(
      calls: calls ?? this.calls,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CallsNotifier extends StateNotifier<CallsState> {
  CallsNotifier() : super(CallsState(calls: _mockCalls, isLoading: true)) {
    _loadCalls();
  }

  static final List<CallModel> _mockCalls = [
    CallModel(
      id: '1',
      contactName: 'Abu G 2',
      contactAvatar: null,
      callType: CallType.audio,
      status: CallStatus.missedIncoming,
      timestamp: DateTime.now().subtract(const Duration(hours: 4)),
      callCount: 5,
    ),
    CallModel(
      id: '2',
      contactName: 'Hajra Api',
      contactAvatar: null,
      callType: CallType.audio,
      status: CallStatus.missedIncoming,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4)),
      callCount: 2,
    ),
    CallModel(
      id: '3',
      contactName: 'Haleema Api & Hajra',
      contactAvatar: null,
      callType: CallType.video,
      status: CallStatus.answeredIncoming,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 4, minutes: 30)),
      callCount: 1,
    ),
    CallModel(
      id: '4',
      contactName: 'Hajra Api',
      contactAvatar: null,
      callType: CallType.audio,
      status: CallStatus.answeredOutgoing,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5)),
      callCount: 1,
    ),
    CallModel(
      id: '5',
      contactName: 'Haleema Api',
      contactAvatar: null,
      callType: CallType.audio,
      status: CallStatus.answeredIncoming,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 5, minutes: 15)),
      callCount: 3,
    ),
    CallModel(
      id: '6',
      contactName: 'Hajra Api',
      contactAvatar: null,
      callType: CallType.audio,
      status: CallStatus.answeredOutgoing,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 6)),
      callCount: 1,
    ),
    CallModel(
      id: '7',
      contactName: 'Haleema Api',
      contactAvatar: null,
      callType: CallType.audio,
      status: CallStatus.answeredOutgoing,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 6, minutes: 15)),
      callCount: 1,
    ),
    CallModel(
      id: '8',
      contactName: 'Abu G 2',
      contactAvatar: null,
      callType: CallType.audio,
      status: CallStatus.missedIncoming,
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 6)),
      callCount: 2,
    ),
    CallModel(
      id: '9',
      contactName: 'Abu G 2',
      contactAvatar: null,
      callType: CallType.audio,
      status: CallStatus.missedIncoming,
      timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 2)),
      callCount: 1,
    ),
    CallModel(
      id: '10',
      contactName: 'Ahmed Nouman 2',
      contactAvatar: null,
      callType: CallType.audio,
      status: CallStatus.answeredOutgoing,
      timestamp: DateTime.now().subtract(const Duration(days: 3, hours: 3)),
      callCount: 1,
    ),
  ];

  Future<void> _loadCalls() async {
    state = state.copyWith(isLoading: true);

    // Simulate API call
    await Future.delayed(const Duration(milliseconds: 500));

    state = state.copyWith(calls: _mockCalls, isLoading: false);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  Future<void> refreshCalls() async {
    await _loadCalls();
  }

  void addCall(CallModel call) {
    state = state.copyWith(calls: [call, ...state.calls]);
  }
}
