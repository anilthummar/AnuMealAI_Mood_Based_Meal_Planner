import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/subscription_config.dart';
import '../../domain/entities/subscription_entity.dart';

class RevenueCatDataSource {
  final _controller = StreamController<SubscriptionEntity>.broadcast();
  bool _isConfigured = false;
  bool _mockJudgeAccess = false;
  SubscriptionEntity _lastKnownState = const SubscriptionEntity();

  static const String _judgeAccessKey = 'mock_judge_access_active';

  Stream<SubscriptionEntity> get stream => _controller.stream;
  SubscriptionEntity get lastKnownState => _lastKnownState;
  bool get isConfigured => _isConfigured;

  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _mockJudgeAccess = prefs.getBool(_judgeAccessKey) ?? false;
      if (_mockJudgeAccess) {
        _emitState(
          const SubscriptionEntity(
            tier: SubscriptionTier.premium,
            status: SubscriptionStatus.premium,
            activeOfferingId: 'shipaton_judge_trial',
          ),
        );
      }
    } catch (_) {}

    final apiKey = Platform.isAndroid
        ? AppConfig.revenueCatApiKeyAndroid
        : (Platform.isIOS ? AppConfig.revenueCatApiKeyIos : '');

    if (apiKey.isEmpty) {
      debugPrint(
        '[RevenueCat] No API key configured. Running in local fallback mode.',
      );
      if (!_mockJudgeAccess) {
        _emitState(const SubscriptionEntity(status: SubscriptionStatus.free));
      }
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
      debugPrint('[RevenueCat] Configured successfully with API key.');
    } catch (e) {
      debugPrint('[RevenueCat] Configuration initialization error: $e');
      if (!_mockJudgeAccess) {
        _emitState(const SubscriptionEntity(status: SubscriptionStatus.free));
      }
    }
  }

  void _handleCustomerInfo(CustomerInfo info) {
    if (_mockJudgeAccess) {
      _emitState(
        const SubscriptionEntity(
          tier: SubscriptionTier.premium,
          status: SubscriptionStatus.premium,
          activeOfferingId: 'shipaton_judge_trial',
        ),
      );
      return;
    }

    // Check primary entitlement 'anumealai_pro' with fallback IDs
    EntitlementInfo? activeEntitlement;
    for (final id in SubscriptionConfig.entitlementIds) {
      final ent = info.entitlements.all[id];
      if (ent != null && ent.isActive) {
        activeEntitlement = ent;
        break;
      }
    }

    final isActive = activeEntitlement != null && activeEntitlement.isActive;

    final newState = SubscriptionEntity(
      tier: isActive ? SubscriptionTier.premium : SubscriptionTier.free,
      status: isActive ? SubscriptionStatus.premium : SubscriptionStatus.free,
      activeOfferingId: activeEntitlement?.productIdentifier,
      expirationDate: activeEntitlement?.expirationDate,
      willRenew: activeEntitlement?.willRenew ?? false,
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
    if (_mockJudgeAccess) {
      return const SubscriptionEntity(
        tier: SubscriptionTier.premium,
        status: SubscriptionStatus.premium,
        activeOfferingId: 'shipaton_judge_trial',
      );
    }
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
        // Look for matching package by identifier (monthly/yearly), packageType, or product identifier
        final cleanId = productId.toLowerCase();
        final pkg = offerings.current!.availablePackages.where((p) {
          final pkgId = p.identifier.toLowerCase();
          final prodId = p.storeProduct.identifier.toLowerCase();
          final isMonthlyMatch =
              (cleanId.contains('month') &&
              (pkgId.contains('month') ||
                  p.packageType == PackageType.monthly ||
                  prodId.contains('month')));
          final isYearlyMatch =
              (cleanId.contains('year') || cleanId.contains('annual')) &&
              (pkgId.contains('year') ||
                  pkgId.contains('annual') ||
                  p.packageType == PackageType.annual ||
                  prodId.contains('year') ||
                  prodId.contains('annual'));

          return pkgId == cleanId ||
              prodId == cleanId ||
              isMonthlyMatch ||
              isYearlyMatch;
        }).firstOrNull;

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

  /// Presents the official RevenueCat Native Paywall UI
  Future<PaywallResult> presentPaywall({Offering? offering}) async {
    if (!_isConfigured) {
      return PaywallResult.notPresented;
    }
    try {
      final result = await RevenueCatUI.presentPaywall(
        offering: offering,
        displayCloseButton: true,
      );
      final info = await Purchases.getCustomerInfo();
      _handleCustomerInfo(info);
      return result;
    } catch (e) {
      debugPrint('[RevenueCatUI] Error presenting Paywall: $e');
      return PaywallResult.error;
    }
  }

  /// Presents the official RevenueCat Native Paywall if entitlement is missing
  Future<PaywallResult> presentPaywallIfNeeded({
    String requiredEntitlement = SubscriptionConfig.premiumEntitlementId,
  }) async {
    if (!_isConfigured) {
      return PaywallResult.notPresented;
    }
    try {
      final result = await RevenueCatUI.presentPaywallIfNeeded(
        requiredEntitlement,
        displayCloseButton: true,
      );
      final info = await Purchases.getCustomerInfo();
      _handleCustomerInfo(info);
      return result;
    } catch (e) {
      debugPrint('[RevenueCatUI] Error presenting PaywallIfNeeded: $e');
      return PaywallResult.error;
    }
  }

  /// Presents RevenueCat Customer Center for managing subscriptions & cancellations
  Future<void> presentCustomerCenter() async {
    if (!_isConfigured) {
      return;
    }
    try {
      await RevenueCatUI.presentCustomerCenter();
      final info = await Purchases.getCustomerInfo();
      _handleCustomerInfo(info);
    } catch (e) {
      debugPrint('[RevenueCatUI] Error presenting Customer Center: $e');
    }
  }

  /// Identifies authenticated Firebase UID in RevenueCat (§27, §40)
  Future<void> logIn(String appUserId) async {
    if (!_isConfigured) return;
    try {
      final logInResult = await Purchases.logIn(appUserId);
      _handleCustomerInfo(logInResult.customerInfo);
      debugPrint('[RevenueCat] Identified user: $appUserId');
    } catch (e) {
      debugPrint('[RevenueCat] Error identifying user $appUserId: $e');
    }
  }

  /// Cleans up user identity on logout (§27, §40)
  Future<void> logOut() async {
    if (!_isConfigured) return;
    try {
      final isAnon = await Purchases.isAnonymous;
      if (!isAnon) {
        final customerInfo = await Purchases.logOut();
        _handleCustomerInfo(customerInfo);
        debugPrint('[RevenueCat] Logged out user session.');
      }
    } catch (e) {
      debugPrint('[RevenueCat] Error logging out user session: $e');
    }
  }

  /// For Shipaton judges testing promo codes (§21)
  Future<void> setMockJudgeAccess(bool enabled) async {
    _mockJudgeAccess = enabled;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_judgeAccessKey, enabled);
    } catch (_) {}

    final state = SubscriptionEntity(
      tier: enabled ? SubscriptionTier.premium : SubscriptionTier.free,
      status: enabled ? SubscriptionStatus.premium : SubscriptionStatus.free,
      activeOfferingId: enabled ? 'shipaton_judge_trial' : null,
    );
    _emitState(state);
  }
}
