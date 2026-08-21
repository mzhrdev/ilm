// lib/features/calls/data/provider/calls_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/features/calls/data/dummy_data/mock_calls.dart';

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
  CallsNotifier() : super(CallsState(calls: mockCalls, isLoading: true)) {
    _loadCalls();
  }

 
  // Load Calls for Call History
  Future<void> _loadCalls() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(calls: mockCalls, isLoading: false);
  }

  // Calls Search Query
  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  // Refresh Calls to update the UI 
  Future<void> refreshCalls() async {
    await _loadCalls();
  }
}
