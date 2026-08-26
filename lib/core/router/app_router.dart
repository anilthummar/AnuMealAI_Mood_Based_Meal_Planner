import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/favorites/presentation/pages/favorites_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/ingredients/presentation/pages/ingredients_page.dart';
import '../../features/meal_planner/presentation/pages/meal_planner_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/recipes/domain/entities/recipe.dart';
import '../../features/recipes/presentation/pages/cooking_mode_page.dart';
import '../../features/recipes/presentation/pages/recipe_detail_page.dart';
import '../../features/recipes/presentation/pages/recipes_page.dart';
import '../../features/settings/presentation/pages/settings_page.dart';
import '../../features/shopping_list/presentation/pages/shopping_list_page.dart';
import '../../features/subscription/presentation/pages/paywall_page.dart';
import '../widgets/luxury_bottom_nav_bar.dart';
import 'app_routes.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static GoRouter createRouter({required bool isOnboardingComplete}) {
    return GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: isOnboardingComplete
          ? AppRoutes.home
          : AppRoutes.onboarding,
      routes: [
        GoRoute(
          path: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingPage(),
        ),
        StatefulShellRoute.indexedStack(
          builder: (context, state, navigationShell) {
            return _ScaffoldWithNavBar(navigationShell: navigationShell);
          },
          branches: [
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.home,
                  builder: (context, state) => const HomePage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.planner,
                  builder: (context, state) => const MealPlannerPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.recipes,
                  builder: (context, state) => const RecipesPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.shopping,
                  builder: (context, state) => const ShoppingListPage(),
                ),
              ],
            ),
            StatefulShellBranch(
              routes: [
                GoRoute(
                  path: AppRoutes.profile,
                  builder: (context, state) => const ProfilePage(),
                ),
              ],
            ),
          ],
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: AppRoutes.ingredients,
          builder: (context, state) => const IngredientsPage(),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: AppRoutes.recipeDetail,
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            final recipe = state.extra as Recipe?;
            return RecipeDetailPage(recipeId: id, initialRecipe: recipe);
          },
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: AppRoutes.cookingMode,
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '';
            final recipe = state.extra as Recipe;
            return CookingModePage(recipeId: id, recipe: recipe);
          },
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: AppRoutes.paywall,
          builder: (context, state) => const PaywallPage(),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: AppRoutes.favorites,
          builder: (context, state) => const FavoritesPage(),
        ),
        GoRoute(
          parentNavigatorKey: _rootNavigatorKey,
          path: AppRoutes.settings,
          builder: (context, state) => const SettingsPage(),
        ),
      ],
    );
  }
}

class _ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const _ScaffoldWithNavBar({required this.navigationShell});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: navigationShell.currentIndex == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && navigationShell.currentIndex != 0) {
          navigationShell.goBranch(0);
        }
      },
      child: Scaffold(
        body: navigationShell,
        bottomNavigationBar: LuxuryBottomNavBar(
          selectedIndex: navigationShell.currentIndex,
          onItemSelected: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          items: const [
            LuxuryBottomNavItem(
              icon: Icons.restaurant_menu_outlined,
              activeIcon: Icons.restaurant_menu_rounded,
              label: 'Dishes',
            ),
            LuxuryBottomNavItem(
              icon: Icons.calendar_today_outlined,
              activeIcon: Icons.calendar_month_rounded,
              label: 'Planner',
            ),
            LuxuryBottomNavItem(
              icon: Icons.auto_awesome_outlined,
              activeIcon: Icons.auto_awesome_rounded,
              label: 'Discover',
              isSpecial: true,
            ),
            LuxuryBottomNavItem(
              icon: Icons.shopping_bag_outlined,
              activeIcon: Icons.shopping_bag_rounded,
              label: 'Shopping',
            ),
            LuxuryBottomNavItem(
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
