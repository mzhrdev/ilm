import 'package:flutter/material.dart';

enum PaymentType { creditCard, debitCard, easyPaisa, jazzCash }

class PaymentMethodModel {
  final String id;
  final String holderName;
  final PaymentType type;
  final String lastFourDigits;
  final String expiryDate;
  final bool isDefault;

  PaymentMethodModel({
    required this.id,
    required this.holderName,
    required this.type,
    required this.lastFourDigits,
    required this.expiryDate,
    this.isDefault = false,
  });

  // Display Name Getter Method
  String get displayName {
    switch (type) {
      case PaymentType.creditCard:
      case PaymentType.debitCard:
        return '**** $lastFourDigits';
      case PaymentType.easyPaisa:
      case PaymentType.jazzCash:
        return lastFourDigits; // Usually phone number for wallets
    }
  }

  // Icon Getter Method
  IconData get icon {
    switch (type) {
      case PaymentType.creditCard:
      case PaymentType.debitCard:
        return Icons.credit_card;
      case PaymentType.easyPaisa:
      case PaymentType.jazzCash:
        return Icons.account_balance_wallet;
    }
  }

  // Type Label Getter Method
  String get typeLabel {
    switch (type) {
      case PaymentType.creditCard:
        return 'Credit Card';
      case PaymentType.debitCard:
        return 'Debit Card';
      case PaymentType.easyPaisa:
        return 'EasyPaisa';
      case PaymentType.jazzCash:
        return 'JazzCash';
    }
  }
}
