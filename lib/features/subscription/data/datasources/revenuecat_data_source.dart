import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/subscription_config.dart';
import '../../domain/entities/subscription_entity.dart';

class RevenueCatDataSource {
  final _controller = StreamController<SubscriptionEntity>.broadcast();
  bool _isConfigured = false;
  SubscriptionEntity _lastKnownState = const SubscriptionEntity();

  Stream<SubscriptionEntity> get stream => _controller.stream;
  SubscriptionEntity get lastKnownState => _lastKnownState;

  Future<void> initialize() async {
    final apiKey = Platform.isAndroid
        ? AppConfig.revenueCatApiKeyAndroid
        : (Platform.isIOS ? AppConfig.revenueCatApiKeyIos : '');

    if (apiKey.isEmpty) {
      debugPrint('[RevenueCat] No API key configured. Running in local fallback mode.');
      _emitState(const SubscriptionEntity(status: SubscriptionStatus.free));
      return;
    }

    try {
      await Purchases.setLogLevel(kDebugMode ? LogLevel.debug : LogLevel.info);
      final configuration = PurchasesConfiguration(apiKey);
      await Purchases.configure(configuration);
      _isConfigured = true;

      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _handleCustomerInfo(customerInfo);
      });

      final info = await Purchases.getCustomerInfo();
      _handleCustomerInfo(info);
    } catch (e) {
      debugPrint('[RevenueCat] Configuration initialization error: $e');
      _emitState(const SubscriptionEntity(status: SubscriptionStatus.free));
    }
  }

  void _handleCustomerInfo(CustomerInfo info) {
    final entitlement = info.entitlements.all[SubscriptionConfig.premiumEntitlementId];
    final isActive = entitlement != null && entitlement.isActive;

    final newState = SubscriptionEntity(
      tier: isActive ? SubscriptionTier.premium : SubscriptionTier.free,
      status: isActive ? SubscriptionStatus.premium : SubscriptionStatus.free,
      activeOfferingId: entitlement?.productIdentifier,
      expirationDate: entitlement?.expirationDate,
      willRenew: entitlement?.willRenew ?? false,
    );

    _emitState(newState);
  }

  void _emitState(SubscriptionEntity state) {
    _lastKnownState = state;
    if (!_controller.isClosed) {
      _controller.add(state);
    }
  }

  Future<SubscriptionEntity> getCustomerInfo() async {
    if (!_isConfigured) {
      return _lastKnownState;
    }
    try {
      final info = await Purchases.getCustomerInfo();
      _handleCustomerInfo(info);
      return _lastKnownState;
    } catch (e) {
      return _lastKnownState;
    }
  }

  Future<Offerings?> getOfferings() async {
    if (!_isConfigured) return null;
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      debugPrint('[RevenueCat] Error fetching offerings: $e');
      return null;
    }
  }

  Future<CustomerInfo?> purchasePackage(Package package) async {
    if (!_isConfigured) return null;
    try {
      final result = await Purchases.purchase(PurchaseParams.package(package));
      _handleCustomerInfo(result.customerInfo);
      return result.customerInfo;
    } catch (e) {
      rethrow;
    }
  }

  Future<CustomerInfo?> purchaseProduct(String productId) async {
    if (!_isConfigured) return null;
    try {
      final offerings = await getOfferings();
      if (offerings != null && offerings.current != null) {
        final pkg = offerings.current!.availablePackages.where((p) => p.storeProduct.identifier == productId).firstOrNull;
        if (pkg != null) {
          final result = await Purchases.purchase(PurchaseParams.package(pkg));
          _handleCustomerInfo(result.customerInfo);
          return result.customerInfo;
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<CustomerInfo?> restorePurchases() async {
    if (!_isConfigured) return null;
    try {
      final customerInfo = await Purchases.restorePurchases();
      _handleCustomerInfo(customerInfo);
      return customerInfo;
    } catch (e) {
      rethrow;
    }
  }

  /// For Shipaton judges testing promo codes (§21)
  void setMockJudgeAccess(bool enabled) {
    final state = SubscriptionEntity(
      tier: enabled ? SubscriptionTier.premium : SubscriptionTier.free,
      status: enabled ? SubscriptionStatus.premium : SubscriptionStatus.free,
      activeOfferingId: 'shipaton_judge_trial',
    );
    _emitState(state);
  }
}
