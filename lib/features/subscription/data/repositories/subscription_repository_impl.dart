import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/premium_status_provider.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/revenuecat_data_source.dart';
import '../utils/subscription_error_mapper.dart';

class SubscriptionRepositoryImpl
    implements SubscriptionRepository, PremiumStatusProvider {
  final RevenueCatDataSource dataSource;

  SubscriptionRepositoryImpl({required this.dataSource});

  @override
  bool get isPremium => dataSource.lastKnownState.isPremium;

  @override
  Stream<bool> get premiumChanges => dataSource.stream.map((s) => s.isPremium);

  @override
  Future<SubscriptionEntity> getSubscriptionState() async {
    return dataSource.getCustomerInfo();
  }

  @override
  Stream<SubscriptionEntity> get subscriptionStream => dataSource.stream;

  @override
  Future<Result<SubscriptionEntity>> purchasePackage(String packageId) async {
    try {
      final info = await dataSource.purchaseProduct(packageId);
      if (info != null && dataSource.lastKnownState.isPremium) {
        return Result.success(dataSource.lastKnownState);
      }
      return const Result.failure(
        SubscriptionFailure('Google Play purchase was not completed.'),
      );
    } catch (e) {
      final friendly = SubscriptionErrorMapper.mapErrorToUserFriendlyMessage(e);
      if (friendly == null) {
        // User cancelled, return empty string so UI doesn't show an error
        return const Result.failure(SubscriptionFailure(''));
      }
      return Result.failure(SubscriptionFailure(friendly));
    }
  }

  @override
  Future<Result<SubscriptionEntity>> restorePurchases() async {
    try {
      final info = await dataSource.restorePurchases();
      if (info != null && dataSource.lastKnownState.isPremium) {
        return Result.success(dataSource.lastKnownState);
      }
      return const Result.failure(
        SubscriptionFailure(
          'No active subscriptions found to restore on Google Play.',
        ),
      );
    } catch (e) {
      final friendly =
          SubscriptionErrorMapper.mapErrorToUserFriendlyMessage(e) ??
          'Unable to restore purchases at this time.';
      return Result.failure(SubscriptionFailure(friendly));
    }
  }

  @override
  Future<Map<String, dynamic>> getOfferings() async {
    String? monthlyPrice;
    String? yearlyPrice;

    final offerings = await dataSource.getOfferings();
    if (offerings != null) {
      Package? monthlyPkg = offerings.current?.monthly;
      Package? annualPkg = offerings.current?.annual;

      if (monthlyPkg == null || annualPkg == null) {
        for (final off in offerings.all.values) {
          monthlyPkg ??= off.monthly;
          annualPkg ??= off.annual;
        }
      }

      if (monthlyPkg != null) monthlyPrice = monthlyPkg.storeProduct.priceString;
      if (annualPkg != null) yearlyPrice = annualPkg.storeProduct.priceString;
    }

    if (monthlyPrice == null || yearlyPrice == null) {
      final prods = await dataSource.getStoreProducts();
      for (final p in prods) {
        if (p.subscriptionOptions != null) {
          for (final opt in p.subscriptionOptions!) {
            final optId = opt.id.toLowerCase();
            final price = opt.pricingPhases.isNotEmpty
                ? opt.pricingPhases.last.price.formatted
                : p.priceString;
            if (optId.contains('month') && monthlyPrice == null) {
              monthlyPrice = price;
            } else if ((optId.contains('year') || optId.contains('annual')) &&
                yearlyPrice == null) {
              yearlyPrice = price;
            }
          }
        }
        if (p.identifier.toLowerCase().contains('month') &&
            monthlyPrice == null) {
          monthlyPrice = p.priceString;
        }
        if ((p.identifier.toLowerCase().contains('year') ||
                p.identifier.toLowerCase().contains('annual')) &&
            yearlyPrice == null) {
          yearlyPrice = p.priceString;
        }
      }
    }

    final map = <String, dynamic>{};
    if (monthlyPrice != null) map['monthly'] = monthlyPrice;
    if (yearlyPrice != null) map['annual'] = yearlyPrice;
    return map;
  }

  @override
  Future<bool> presentPaywall() async {
    final result = await dataSource.presentPaywall();
    return result == PaywallResult.purchased ||
        result == PaywallResult.restored;
  }

  @override
  Future<bool> presentPaywallIfNeeded() async {
    final result = await dataSource.presentPaywallIfNeeded();
    return result == PaywallResult.purchased ||
        result == PaywallResult.restored;
  }

  @override
  Future<void> presentCustomerCenter() async {
    await dataSource.presentCustomerCenter();
  }

  Future<void> setJudgeAccess(bool enabled) async {
    await dataSource.setMockJudgeAccess(enabled);
  }
}
