import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'core/constants/hive_boxes.dart';
import 'core/dependency_injection/di.dart';
import 'core/services/firebase_service.dart';
import 'features/profile/domain/repositories/profile_repository.dart';
import 'features/subscription/data/datasources/revenuecat_data_source.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize local persistence (Hive)
  await Hive.initFlutter();
  for (final boxName in HiveBoxes.all) {
    await Hive.openBox<Map>(boxName);
  }

  // 2. Initialize Dependency Injection container
  await initDependencyInjection();

  // 3. Initialize Firebase & RevenueCat SDKs safely in the background
  try {
    await sl<FirebaseService>().initialize();
  } catch (e) {
    debugPrint('[Main] Firebase initial setup warning: $e');
  }

  try {
    await sl<RevenueCatDataSource>().initialize();
  } catch (e) {
    debugPrint('[Main] RevenueCat initial setup warning: $e');
  }

  // 4. Determine initial launch route (First-run vs Returning user, §47)
  final profileRepo = sl<ProfileRepository>();
  final isOnboardingComplete = await profileRepo.isOnboardingCompleted();

  runApp(AnuMealAiApp(isOnboardingComplete: isOnboardingComplete));
}
