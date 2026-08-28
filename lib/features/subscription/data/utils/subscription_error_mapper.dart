import 'package:flutter/services.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

/// Maps raw platform and store exceptions into clean, human-friendly messages (§21, §25).
/// Prevents exposing raw PlatformException or developer dictionaries to users.
class SubscriptionErrorMapper {
  SubscriptionErrorMapper._();

  static const String storePendingCode = 'STORE_PENDING_REVIEW';

  static String? mapErrorToUserFriendlyMessage(dynamic error) {
    if (error == null) return null;

    if (error is PlatformException) {
      final details = error.details;
      if (details is Map && details['userCancelled'] == true) {
        return null; // User cancelled without error
      }

      try {
        final errorCode = PurchasesErrorHelper.getErrorCode(error);
        if (errorCode == PurchasesErrorCode.purchaseCancelledError) {
          return null; // Silent cancellation
        }

        if (errorCode == PurchasesErrorCode.networkError) {
          return 'Unable to connect to Google Play. Please check your internet connection.';
        }

        if (errorCode == PurchasesErrorCode.productAlreadyPurchasedError) {
          return 'You already own this subscription. Tap "Restore Purchases" to activate.';
        }

        if (errorCode == PurchasesErrorCode.purchaseNotAllowedError) {
          return 'Purchases are restricted on this device or Google account.';
        }

        if (errorCode == PurchasesErrorCode.paymentPendingError) {
          return 'Your payment is pending in Google Play. It will activate once confirmed.';
        }
      } catch (_) {}

      final errorStr = error.toString().toLowerCase();
      final message = (error.message ?? '').toLowerCase();
      final underlying = (details is Map
              ? details['underlyingErrorMessage']?.toString() ?? ''
              : '')
          .toLowerCase();

      if (errorStr.contains('developer_error') ||
          errorStr.contains('not configured for billing') ||
          errorStr.contains('app version has been published') ||
          underlying.contains('developer_error') ||
          underlying.contains('published') ||
          message.contains('invalid') ||
          error.code == '4') {
        return storePendingCode;
      }
    }

    final raw = error.toString().toLowerCase();
    if (raw.contains('usercancelled') ||
        raw.contains('cancelled') ||
        raw.contains('canceled')) {
      return null;
    }

    if (raw.contains('developer_error') ||
        raw.contains('not configured for billing') ||
        raw.contains('app version has been published')) {
      return storePendingCode;
    }

    if (raw.contains('network') ||
        raw.contains('socket') ||
        raw.contains('timed out')) {
      return 'Unable to connect to Google Play. Please check your internet connection.';
    }

    return 'Google Play purchase could not be completed right now. Please try again or use the Promo Pass.';
  }
}
