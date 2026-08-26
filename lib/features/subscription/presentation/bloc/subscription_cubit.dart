import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/subscription_config.dart';
import '../../../../core/services/analytics_service.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import 'subscription_state.dart';

class SubscriptionCubit extends Cubit<SubscriptionState> {
  final SubscriptionRepository subscriptionRepository;
  final AnalyticsService analytics;
  StreamSubscription? _subscription;

  SubscriptionCubit({
    required this.subscriptionRepository,
    required this.analytics,
  }) : super(const SubscriptionState()) {
    _init();
  }

  void _init() {
    _subscription = subscriptionRepository.subscriptionStream.listen((sub) {
      emit(state.copyWith(subscription: sub));
      if (sub.isPremium) {
        analytics.logSubscriptionActive();
      }
    });
    loadSubscription();
  }

  Future<void> loadSubscription() async {
    try {
      final sub = await subscriptionRepository.getSubscriptionState();
      final offerings = await subscriptionRepository.getOfferings();
      emit(state.copyWith(
        subscription: sub,
        monthlyPrice: offerings['monthly'] ?? state.monthlyPrice,
        yearlyPrice: offerings['annual'] ?? state.yearlyPrice,
      ));
    } catch (_) {}
  }

  Future<bool> purchaseMonthly() async {
    return _purchase(SubscriptionConfig.monthlyProductId);
  }

  Future<bool> purchaseYearly() async {
    return _purchase(SubscriptionConfig.yearlyProductId);
  }

  Future<bool> _purchase(String productId) async {
    emit(state.copyWith(isPurchasing: true, errorMessage: null));
    await analytics.logPurchaseStarted(productId);

    final result = await subscriptionRepository.purchasePackage(productId);
    if (result.isSuccess) {
      await analytics.logPurchaseCompleted(productId);
      emit(state.copyWith(
        isPurchasing: false,
        subscription: result.dataOrNull ?? const SubscriptionEntity(tier: SubscriptionTier.premium),
        successMessage: 'Welcome to AnuMealAI Premium! ✨',
      ));
      return true;
    } else {
      final errMsg = result.failureOrNull?.message ?? 'Purchase failed';
      await analytics.logPurchaseFailed(errMsg);
      emit(state.copyWith(
        isPurchasing: false,
        errorMessage: errMsg,
      ));
      return false;
    }
  }

  Future<bool> restorePurchases() async {
    emit(state.copyWith(isRestoring: true, errorMessage: null));
    await analytics.logRestorePurchase();

    final result = await subscriptionRepository.restorePurchases();
    if (result.isSuccess) {
      emit(state.copyWith(
        isRestoring: false,
        subscription: result.dataOrNull ?? const SubscriptionEntity(tier: SubscriptionTier.premium),
        successMessage: 'Purchases restored successfully! ✨',
      ));
      return true;
    } else {
      emit(state.copyWith(
        isRestoring: false,
        errorMessage: result.failureOrNull?.message ?? 'No active purchases found.',
      ));
      return false;
    }
  }

  /// Shipaton 2026 Judge Free Trial / Promo Code Access (§21)
  bool redeemPromoOrTrial(String code) {
    final clean = code.trim().toUpperCase();
    if (clean == 'SHIPATON2026' || clean == 'JUDGE_ACCESS' || clean == 'FREE_TRIAL') {
      if (subscriptionRepository is SubscriptionRepositoryImpl) {
        (subscriptionRepository as SubscriptionRepositoryImpl).setJudgeAccess(true);
      }
      emit(state.copyWith(
        subscription: const SubscriptionEntity(
          tier: SubscriptionTier.premium,
          status: SubscriptionStatus.premium,
          activeOfferingId: 'shipaton_judge_trial',
        ),
        successMessage: '🎉 Shipaton Judge Trial Unlocked! Full premium access enabled.',
      ));
      return true;
    }
    emit(state.copyWith(errorMessage: 'Invalid promo code. Check code and try again.'));
    return false;
  }

  void clearMessages() {
    emit(state.copyWith(errorMessage: null, successMessage: null));
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
