import 'package:lms/features/payment/data/model/payment_method_model.dart';

final List<PaymentMethodModel> mockMethods = [
  PaymentMethodModel(
    id: '1',
    holderName: 'Fawais',
    type: PaymentType.creditCard,
    lastFourDigits: '4242',
    expiryDate: '12/26',
    isDefault: true,
  ),
  PaymentMethodModel(
    id: '2',
    holderName: 'Fawais',
    type: PaymentType.easyPaisa,
    lastFourDigits: '03001234567',
    expiryDate: '',
    isDefault: false,
  ),
];
