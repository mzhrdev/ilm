// lib/features/calls/data/provider/calls_provider.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/core/data/services/call_firestore_services.dart';
import 'package:lms/features/auth/data/providers/auth_provider.dart';
import '../model/call_model.dart';

// Call Firestore Provider
final callFirestoreServiceProvider = Provider<CallFirestoreService>((ref) {
  return CallFirestoreService();
});

final callsProvider = StateNotifierProvider<CallsNotifier, CallsState>((ref) {
  return CallsNotifier(ref);
});

class CallsState {
  final List<CallModel> calls;
  final bool isLoading;
  final String searchQuery;

  CallsState({
    required this.calls,
    this.isLoading = false,
    this.searchQuery = '',
  });

  List<CallModel> get filteredCalls {
    if (searchQuery.isEmpty) {
      return calls;
    }
    return calls
        .where((call) => call.contactName.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  CallsState copyWith({
    List<CallModel>? calls,
    bool? isLoading,
    String? searchQuery,
  }) {
    return CallsState(
      calls: calls ?? this.calls,
      isLoading: isLoading ?? this.isLoading,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class CallsNotifier extends StateNotifier<CallsState> {
  final Ref _ref;
  StreamSubscription<List<CallModel>>? _historySubscription;

  CallsNotifier(this._ref) : super(CallsState(calls: [], isLoading: true)) {
    _initCallHistoryListener();
  }

  void _initCallHistoryListener() {
    state = state.copyWith(isLoading: true);

    // Watch current user state to bind the real-time call history stream
    final currentUser = _ref.watch(currentUserProvider);

    if (currentUser == null) {
      state = state.copyWith(calls: [], isLoading: false);
      return;
    }

    _historySubscription?.cancel();
    _historySubscription = _ref
        .read(callFirestoreServiceProvider)
        .getCallHistoryStream(currentUser.id)
        .listen(
      (history) {
        state = state.copyWith(calls: history, isLoading: false);
      },
      onError: (error) {
        state = state.copyWith(isLoading: false);
      },
    );
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  @override
  void dispose() {
    _historySubscription?.cancel();
    super.dispose();
  }
}