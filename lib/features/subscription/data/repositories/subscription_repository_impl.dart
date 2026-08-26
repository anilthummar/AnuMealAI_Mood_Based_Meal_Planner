import '../../../../core/errors/failures.dart';
import '../../../../core/services/premium_status_provider.dart';
import '../../../../core/utils/result.dart';
import '../../domain/entities/subscription_entity.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/revenuecat_data_source.dart';

class SubscriptionRepositoryImpl implements SubscriptionRepository, PremiumStatusProvider {
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
      return const Result.failure(SubscriptionFailure('Purchase could not be completed.'));
    } catch (e) {
      return Result.failure(SubscriptionFailure(e.toString()));
    }
  }

  @override
  Future<Result<SubscriptionEntity>> restorePurchases() async {
    try {
      final info = await dataSource.restorePurchases();
      if (info != null && dataSource.lastKnownState.isPremium) {
        return Result.success(dataSource.lastKnownState);
      }
      return const Result.failure(SubscriptionFailure('No active subscriptions found to restore.'));
    } catch (e) {
      return Result.failure(SubscriptionFailure('Error restoring purchases: $e'));
    }
  }

  @override
  Future<Map<String, dynamic>> getOfferings() async {
    final offerings = await dataSource.getOfferings();
    if (offerings == null || offerings.current == null) {
      return {};
    }
    return {
      'current': offerings.current!.identifier,
      'monthly': offerings.current!.monthly?.storeProduct.priceString ?? '\$4.99/mo',
      'annual': offerings.current!.annual?.storeProduct.priceString ?? '\$39.99/yr',
    };
  }

  void setJudgeAccess(bool enabled) {
    dataSource.setMockJudgeAccess(enabled);
  }
}
