/// Named route paths used across the application (§11, §24, §60).
class AppRoutes {
  AppRoutes._();

  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/';
  static const String planner = '/planner';
  static const String recipes = '/recipes';
  static const String shopping = '/shopping';
  static const String profile = '/profile';
  static const String ingredients = '/ingredients';
  static const String recipeDetail = '/recipe/:id';
  static const String cookingMode = '/cooking-mode/:id';
  static const String paywall = '/paywall';
  static const String favorites = '/favorites';
  static const String settings = '/settings';
  static const String termsOfUse = '/legal/terms';
  static const String privacyPolicy = '/legal/privacy';
  static const String deleteAccount = '/account/delete';
  static const String maintenance = '/maintenance';

  static String recipeDetailPath(String id) => '/recipe/$id';
  static String cookingModePath(String id) => '/cooking-mode/$id';
}
