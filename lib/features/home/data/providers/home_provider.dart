import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier();
});

class HomeState {
  // Constructor
  HomeState({required this.homeSearchController});
  // TextEditingController
  final TextEditingController homeSearchController;

  HomeState copyWith({TextEditingController? homeSearchController}) {
    return HomeState(homeSearchController: homeSearchController ?? this.homeSearchController);
  }
}

class HomeNotifier extends StateNotifier<HomeState> {
  HomeNotifier() : super(HomeState(homeSearchController: TextEditingController()));
}
