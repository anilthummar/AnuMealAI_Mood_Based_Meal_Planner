import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/remote_config_keys.dart';
import '../../../../core/constants/subscription_config.dart';
import '../../domain/entities/subscription_entity.dart';

class RevenueCatDataSource {
  final FirebaseRemoteConfig? firebaseRemoteConfig;
  final FirebaseFirestore? firestore;
  final FirebaseAuth? firebaseAuth;
  final _controller = StreamController<SubscriptionEntity>.broadcast();
  bool _isConfigured = false;
  bool _mockJudgeAccess = false;
  SubscriptionEntity _lastKnownState = const SubscriptionEntity();

  RevenueCatDataSource({
    this.firebaseRemoteConfig,
    this.firestore,
    this.firebaseAuth,
  });

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

    // Check Cloud Firestore for persistent restored subscription
    if (firestore != null && firebaseAuth?.currentUser != null) {
      try {
        final uid = firebaseAuth!.currentUser!.uid;
        final doc = await firestore!.collection('users').doc(uid).get();
        if (doc.exists && doc.data()?['isPremium'] == true) {
          final offId = doc.data()?['activeOfferingId'] as String?;
          _mockJudgeAccess = true;
          _emitState(
            SubscriptionEntity(
              tier: SubscriptionTier.premium,
              status: SubscriptionStatus.premium,
              activeOfferingId: offId ?? 'shipaton_judge_trial',
            ),
          );
        }
      } catch (e) {
        debugPrint('[RevenueCat] Firestore subscription check note: $e');
      }
    }

    String apiKey = '';
    if (Platform.isAndroid) {
      if (firebaseRemoteConfig != null) {
        try {
          final rcKey = firebaseRemoteConfig!
              .getString(RemoteConfigKeys.revenueCatApiKeyAndroid)
              .trim();
          if (rcKey.isNotEmpty) apiKey = rcKey;
        } catch (_) {}
      }
      if (apiKey.isEmpty) {
        apiKey = AppConfig.revenueCatApiKeyAndroid;
      }
    } else if (Platform.isIOS) {
      if (firebaseRemoteConfig != null) {
        try {
          final rcKey = firebaseRemoteConfig!
              .getString(RemoteConfigKeys.revenueCatApiKeyIos)
              .trim();
          if (rcKey.isNotEmpty) apiKey = rcKey;
        } catch (_) {}
      }
      if (apiKey.isEmpty) {
        apiKey = AppConfig.revenueCatApiKeyIos;
      }
    }

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
    _syncToFirestore(state);
  }

  Future<void> _syncToFirestore(SubscriptionEntity state) async {
    if (firestore == null || firebaseAuth?.currentUser == null) return;
    try {
      final uid = firebaseAuth!.currentUser!.uid;
      await firestore!.collection('users').doc(uid).set({
        'isPremium': state.isPremium,
        'subscriptionTier': state.tier.name,
        'subscriptionStatus': state.status.name,
        'activeOfferingId': state.activeOfferingId,
        'subscriptionUpdatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      debugPrint(
        '[RevenueCat] Synced subscription state to Firestore users/$uid (isPremium: ${state.isPremium})',
      );
    } catch (e) {
      debugPrint('[RevenueCat] Firestore subscription sync note: $e');
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
    if (!_isConfigured) {
      await initialize();
    }
    if (!_isConfigured) {
      throw Exception('Store connection is initializing. Please try again.');
    }

    final cleanId = productId.toLowerCase();

    try {
      final offerings = await getOfferings();
      Package? targetPkg;

      if (offerings != null) {
        final allPackages = <Package>[];
        if (offerings.current != null) {
          allPackages.addAll(offerings.current!.availablePackages);
        }
        for (final off in offerings.all.values) {
          allPackages.addAll(off.availablePackages);
        }

        targetPkg = allPackages.where((p) {
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
      }

      if (targetPkg != null) {
        final result = await Purchases.purchase(
          PurchaseParams.package(targetPkg),
        );
        _handleCustomerInfo(result.customerInfo);
        return result.customerInfo;
      }

      // If no offering package matched, attempt direct store product purchase with subscription options
      final storeProducts = await Purchases.getProducts([
        'anumealai_premium',
        productId,
        'anumealai_premium:monthly',
        'anumealai_premium:yearly',
        'monthly',
        'yearly',
      ]);

      if (storeProducts.isNotEmpty) {
        final prod = storeProducts.first;
        final isYearly = cleanId.contains('year') || cleanId.contains('annual');

        SubscriptionOption? targetOption;
        if (prod.subscriptionOptions != null &&
            prod.subscriptionOptions!.isNotEmpty) {
          targetOption =
              prod.subscriptionOptions!.where((opt) {
                final optId = opt.id.toLowerCase();
                return isYearly
                    ? (optId.contains('year') || optId.contains('annual'))
                    : optId.contains('month');
              }).firstOrNull ??
              prod.defaultOption;
        }

        if (targetOption != null) {
          final result = await Purchases.purchase(
            PurchaseParams.subscriptionOption(targetOption),
          );
          _handleCustomerInfo(result.customerInfo);
          return result.customerInfo;
        } else {
          final result = await Purchases.purchase(
            PurchaseParams.storeProduct(prod),
          );
          _handleCustomerInfo(result.customerInfo);
          return result.customerInfo;
        }
      }

      throw Exception(
        'Subscription product ($productId) not found in store offering. Please check Play Store test track.',
      );
    } catch (e) {
      debugPrint('[RevenueCat] purchaseProduct error: $e');
      rethrow;
    }
  }

  Future<List<StoreProduct>> getStoreProducts() async {
    if (!_isConfigured) {
      await initialize();
    }
    if (!_isConfigured) return [];
    try {
      return await Purchases.getProducts([
        'anumealai_premium',
        SubscriptionConfig.monthlyProductId,
        SubscriptionConfig.yearlyProductId,
      ]);
    } catch (e) {
      debugPrint('[RevenueCat] Error getting store products: $e');
      return [];
    }
  }

  Future<CustomerInfo?> restorePurchases() async {
    CustomerInfo? customerInfo;
    if (_isConfigured) {
      try {
        customerInfo = await Purchases.restorePurchases();
        _handleCustomerInfo(customerInfo);
      } catch (e) {
        debugPrint('[RevenueCat] Purchases.restorePurchases warning: $e');
      }
    }

    // Check Cloud Firestore backup
    if (firestore != null && firebaseAuth?.currentUser != null) {
      try {
        final uid = firebaseAuth!.currentUser!.uid;
        final doc = await firestore!.collection('users').doc(uid).get();
        if (doc.exists && doc.data()?['isPremium'] == true) {
          await setMockJudgeAccess(true);
          return customerInfo;
        }
      } catch (e) {
        debugPrint('[RevenueCat] Firestore restore check note: $e');
      }
    }

    if (customerInfo != null) return customerInfo;
    if (_mockJudgeAccess || _lastKnownState.isPremium) return null;
    return null;
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
    if (_isConfigured) {
      try {
        final logInResult = await Purchases.logIn(appUserId);
        _handleCustomerInfo(logInResult.customerInfo);
        debugPrint('[RevenueCat] Identified user: $appUserId');
      } catch (e) {
        debugPrint('[RevenueCat] Error identifying user $appUserId: $e');
      }
    }

    // Check Cloud Firestore for active subscription
    if (firestore != null) {
      try {
        final doc = await firestore!.collection('users').doc(appUserId).get();
        if (doc.exists && doc.data()?['isPremium'] == true) {
          final offId = doc.data()?['activeOfferingId'] as String?;
          await setMockJudgeAccess(true);
          _emitState(
            SubscriptionEntity(
              tier: SubscriptionTier.premium,
              status: SubscriptionStatus.premium,
              activeOfferingId: offId ?? 'shipaton_judge_trial',
            ),
          );
        }
      } catch (e) {
        debugPrint(
          '[RevenueCat] Error checking Firestore for user $appUserId: $e',
        );
      }
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
