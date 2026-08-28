import 'package:extensions_kit/extensions_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lms/core/constants/app_colors.dart';
import 'package:lms/core/constants/app_text_styles.dart';
import 'package:lms/core/presentation/widgets/custom_icon_button.dart';
import 'package:lms/core/presentation/widgets/custom_safe_area.dart';
import 'package:lms/features/payment/data/provider/payment_method_provider.dart';
import 'package:lms/features/payment/presentation/widget/payment_method_tile_widget.dart';

class PaymentMethodsScreen extends ConsumerWidget {
  const PaymentMethodsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paymentMethodsProvider);
    return CustomSafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.kWhite,
          elevation: 0,
          leading: CustomIconButton(
            onTap: () {},
            icon: Icons.arrow_back_ios_new,
            iconColor: AppColors.kBlack,
            paddingAroundIcon: context.w(4.75),
          ),
          title: const Text('Payment Methods', style: AppTextStyle.kHeading),
        ),
        body: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.methods.isEmpty
            ? _buildEmptyState(ref, context)
            : Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.all(context.h(2)),
                      itemCount: state.methods.length,
                      itemBuilder: (context, index) {
                        final method = state.methods[index];
                        return PaymentMethodTile(
                          method: method,
                          isSelected: method.isDefault,
                          onTap: () {
                            ref.read(paymentMethodsProvider.notifier).setDefaultMethod(method.id);
                          },
                          onDelete: () {
                            ref.read(paymentMethodsProvider.notifier).removeMethod(method.id);
                          },
                        );
                      },
                    ),
                  ),

                  // Add New Method Button
                  SizedBox(
                    width: double.infinity,
                    height: context.h(6),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ref.read(paymentMethodsProvider.notifier).addNewMethod();
                        ScaffoldMessenger.of(
                          context,
                        ).showSnackBar(const SnackBar(content: Text('Add Card Screen coming soon!')));
                      },
                      icon: Icon(Icons.add, color: AppColors.kWhite, size: context.h(3)),
                      label: Text(
                        'Add New Payment Method',
                        style: AppTextStyle.kSectionTitle.copyWith(color: AppColors.kWhite),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.kBlack,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.w(4))),
                      ),
                    ),
                  ).padAll(context.w(4)),
                ],
              ),
      ),
    );
  }

  // Empty State Builder
  Widget _buildEmptyState(WidgetRef ref, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card_off, size: context.h(8), color: AppColors.kGrey),
          SizedBox(height: context.h(2)),
          Text(
            'No payment methods',
            style: AppTextStyle.kBodyLarge.copyWith(color: AppColors.kBlack.withAlpha(170)),
          ),
          SizedBox(height: 8),
          Text(
            'Add a card or wallet to make payments easily.',
            style: AppTextStyle.kBodyMedium.copyWith(color: AppColors.kBlack.withAlpha(120)),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: context.h(2)),
          SizedBox(
            width: double.infinity,
            height: context.h(6),
            child: ElevatedButton(
              onPressed: () => ref.read(paymentMethodsProvider.notifier).addNewMethod(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.kBlack,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(context.w(4))),
              ),
              child: Text(
                'Add Payment Method',
                style: AppTextStyle.kSectionTitle.copyWith(color: AppColors.kWhite),
              ),
            ),
          ),
        ],
      ).padAll(context.w(5)),
    );
  }
}
