import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

import '../constants/app_config.dart';

/// Helper service to safely launch external URLs (Terms, Privacy, Web links).
class UrlLauncherService {
  UrlLauncherService._();

  static Future<bool> openUrl(String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        // Fallback to platform default
        return await launchUrl(uri);
      }
      return launched;
    } catch (e) {
      debugPrint('[UrlLauncherService] Could not launch $urlString: $e');
      return false;
    }
  }

  static Future<bool> openTermsOfUse() => openUrl(AppConfig.termsOfUseUrl);

  static Future<bool> openPrivacyPolicy() =>
      openUrl(AppConfig.privacyPolicyUrl);

  static Future<bool> openPlayStoreRedeem([String? code]) {
    final clean = code?.trim();
    final url = (clean != null && clean.isNotEmpty)
        ? 'https://play.google.com/redeem?code=${Uri.encodeComponent(clean)}'
        : 'https://play.google.com/redeem';
    return openUrl(url);
  }
}
