import '../../../../core/utils/result.dart';
import '../entities/subscription_entity.dart';

abstract class SubscriptionRepository {
  Future<SubscriptionEntity> getSubscriptionState();
  Stream<SubscriptionEntity> get subscriptionStream;
  Future<Result<SubscriptionEntity>> purchasePackage(String packageId);
  Future<Result<SubscriptionEntity>> restorePurchases();
  Future<Map<String, dynamic>> getOfferings();
}
