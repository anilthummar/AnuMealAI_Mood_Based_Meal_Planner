import 'package:flutter_test/flutter_test.dart';
import 'package:anu_meal_ai/core/services/app_version_service.dart';

void main() {
  group('AppVersionService Semantic Version Comparison Tests (§22, §58)', () {
    test('Correctly identifies 1.0.9 < 1.0.10 (multi-digit minor/patch)', () {
      expect(AppVersionService.compareVersions('1.0.9', '1.0.10'), lessThan(0));
      expect(
        AppVersionService.compareVersions('1.0.10', '1.0.9'),
        greaterThan(0),
      );
    });

    test('Correctly identifies equal versions', () {
      expect(AppVersionService.compareVersions('1.0.0', '1.0.0'), equals(0));
      expect(AppVersionService.compareVersions('2.1.5', '2.1.5'), equals(0));
    });

    test('Correctly identifies major version increments', () {
      expect(AppVersionService.compareVersions('1.9.9', '2.0.0'), lessThan(0));
      expect(
        AppVersionService.compareVersions('2.0.0', '1.9.9'),
        greaterThan(0),
      );
    });

    test('Correctly handles varying segment lengths', () {
      expect(AppVersionService.compareVersions('1.0', '1.0.0'), equals(0));
      expect(AppVersionService.compareVersions('1.0.1', '1.0'), greaterThan(0));
    });

    test('isUpdateRequired returns true when current < minVersion', () {
      expect(
        AppVersionService.isUpdateRequired(
          currentVersion: '1.0.0',
          minVersion: '1.0.1',
        ),
        isTrue,
      );
      expect(
        AppVersionService.isUpdateRequired(
          currentVersion: '1.1.0',
          minVersion: '1.0.1',
        ),
        isFalse,
      );
    });

    test('isUpdateAvailable returns true when current < latestVersion', () {
      expect(
        AppVersionService.isUpdateAvailable(
          currentVersion: '1.0.0',
          latestVersion: '1.1.0',
        ),
        isTrue,
      );
      expect(
        AppVersionService.isUpdateAvailable(
          currentVersion: '1.1.0',
          latestVersion: '1.1.0',
        ),
        isFalse,
      );
    });
  });
}
