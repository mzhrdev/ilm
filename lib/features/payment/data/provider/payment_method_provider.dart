// lib/features/settings/data/provider/payment_methods_provider.dart

import 'package:Edvance/features/payment/data/dummy_data/payment_method.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../model/payment_method_model.dart';

final paymentMethodsProvider = StateNotifierProvider<PaymentMethodsNotifier, PaymentMethodsState>((ref) {
  return PaymentMethodsNotifier();
});

class PaymentMethodsState {
  final List<PaymentMethodModel> methods;
  final bool isLoading;

  PaymentMethodsState({required this.methods, this.isLoading = false});

  PaymentMethodsState copyWith({List<PaymentMethodModel>? methods, bool? isLoading}) {
    return PaymentMethodsState(methods: methods ?? this.methods, isLoading: isLoading ?? this.isLoading);
  }
}

class PaymentMethodsNotifier extends StateNotifier<PaymentMethodsState> {
  PaymentMethodsNotifier() : super(PaymentMethodsState(methods: mockMethods, isLoading: true)) {
    _loadMethods();
  }

 
  Future<void> _loadMethods() async {
    state = state.copyWith(isLoading: true);
    await Future.delayed(const Duration(milliseconds: 500));
    state = state.copyWith(methods: mockMethods, isLoading: false);
  }

  void setDefaultMethod(String methodId) {
    state = state.copyWith(
      methods: state.methods.map((method) {
        return PaymentMethodModel(
          id: method.id,
          holderName: method.holderName,
          type: method.type,
          lastFourDigits: method.lastFourDigits,
          expiryDate: method.expiryDate,
          isDefault: method.id == methodId, // Set the selected one as default
        );
      }).toList(),
    );
  }

  void removeMethod(String methodId) {
    state = state.copyWith(methods: state.methods.where((method) => method.id != methodId).toList());
  }

  void addNewMethod() {
    // TODO: Navigate to Add Card Screen
    // For now, we just add a mock method
    final newMethod = PaymentMethodModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      holderName: 'Fawais',
      type: PaymentType.debitCard,
      lastFourDigits: '8888',
      expiryDate: '01/28',
      isDefault: false,
    );
    state = state.copyWith(methods: [...state.methods, newMethod]);
  }
}
