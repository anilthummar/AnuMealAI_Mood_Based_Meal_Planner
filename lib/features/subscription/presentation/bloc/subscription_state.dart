import 'package:equatable/equatable.dart';

import '../../domain/entities/subscription_entity.dart';

class SubscriptionState extends Equatable {
  final SubscriptionEntity subscription;
  final bool isPurchasing;
  final bool isRestoring;
  final String? errorMessage;
  final String? successMessage;
  final String monthlyPrice;
  final String yearlyPrice;

  const SubscriptionState({
    this.subscription = const SubscriptionEntity(),
    this.isPurchasing = false,
    this.isRestoring = false,
    this.errorMessage,
    this.successMessage,
    this.monthlyPrice = '\$4.99 / month',
    this.yearlyPrice = '\$39.99 / year',
  });

  bool get isPremium => subscription.isPremium;

  SubscriptionState copyWith({
    SubscriptionEntity? subscription,
    bool? isPurchasing,
    bool? isRestoring,
    String? errorMessage,
    String? successMessage,
    String? monthlyPrice,
    String? yearlyPrice,
  }) {
    return SubscriptionState(
      subscription: subscription ?? this.subscription,
      isPurchasing: isPurchasing ?? this.isPurchasing,
      isRestoring: isRestoring ?? this.isRestoring,
      errorMessage: errorMessage,
      successMessage: successMessage,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      yearlyPrice: yearlyPrice ?? this.yearlyPrice,
    );
  }

  @override
  List<Object?> get props => [
        subscription,
        isPurchasing,
        isRestoring,
        errorMessage,
        successMessage,
        monthlyPrice,
        yearlyPrice,
      ];
}
