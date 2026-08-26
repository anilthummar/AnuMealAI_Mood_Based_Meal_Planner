import 'package:package_info_plus/package_info_plus.dart';

/// Semantic App Version Comparator & Update Evaluation Service (§20, §21, §22).
class AppVersionService {
  const AppVersionService();

  /// Compares two version strings (e.g., "1.0.9" vs "1.0.10" or "1.0.0+2").
  /// Returns:
  /// - Negative integer if [v1] < [v2]
  /// - Zero if [v1] == [v2]
  /// - Positive integer if [v1] > [v2]
  static int compareVersions(String v1, String v2) {
    final clean1 = _cleanVersion(v1);
    final clean2 = _cleanVersion(v2);

    final parts1 = clean1.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final parts2 = clean2.split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLen = parts1.length > parts2.length ? parts1.length : parts2.length;

    for (int i = 0; i < maxLen; i++) {
      final p1 = i < parts1.length ? parts1[i] : 0;
      final p2 = i < parts2.length ? parts2[i] : 0;

      if (p1 != p2) {
        return p1.compareTo(p2);
      }
    }

    return 0;
  }

  /// Removes build metadata (e.g., "+1") and extra spaces before comparison
  static String _cleanVersion(String version) {
    final trimmed = version.trim();
    if (trimmed.contains('+')) {
      return trimmed.split('+').first;
    }
    return trimmed;
  }

  /// Checks if installed version is strictly lower than the minimum required version
  static bool isUpdateRequired({
    required String currentVersion,
    required String minVersion,
  }) {
    if (minVersion.trim().isEmpty) return false;
    return compareVersions(currentVersion, minVersion) < 0;
  }

  /// Checks if a newer version is available on the store (soft update)
  static bool isUpdateAvailable({
    required String currentVersion,
    required String latestVersion,
  }) {
    if (latestVersion.trim().isEmpty) return false;
    return compareVersions(currentVersion, latestVersion) < 0;
  }

  /// Retrieves the current version string from platform metadata
  Future<String> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.version;
    } catch (_) {
      return '1.0.0';
    }
  }

  /// Retrieves the current build number from platform metadata
  Future<String> getBuildNumber() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return packageInfo.buildNumber;
    } catch (_) {
      return '1';
    }
  }
}
