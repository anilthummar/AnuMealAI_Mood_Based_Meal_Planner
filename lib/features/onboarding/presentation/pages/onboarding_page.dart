import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/onboarding_cubit.dart';
import '../bloc/onboarding_state.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;
  final TextEditingController _nameController = TextEditingController(
    text: 'Anu',
  );

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state.status == OnboardingStatus.completed) {
          context.go(AppRoutes.home);
        }
      },
      builder: (context, state) {
        final cubit = context.read<OnboardingCubit>();

        return Scaffold(
          backgroundColor: scheme.surface,
          body: SafeArea(
            child: Column(
              children: [
                // Top Progress Bar and Navigation
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    children: [
                      if (!state.isFirstStep && !state.isLastStep)
                        IconButton(
                          icon: Icon(
                            Icons.chevron_left_rounded,
                            color: scheme.onSurface,
                            size: 28,
                          ),
                          onPressed: () {
                            cubit.previousStep();
                            _goToPage(state.currentStep - 1);
                          },
                        )
                      else
                        const SizedBox(width: 48),
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusPill,
                          ),
                          child: LinearProgressIndicator(
                            value: state.progress,
                            minHeight: 6,
                            backgroundColor: isDark
                                ? const Color(0xFF282828)
                                : scheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              scheme.primary,
                            ),
                          ),
                        ),
                      ),
                      if (!state.isLastStep)
                        TextButton(
                          onPressed: () async {
                            await cubit.completeOnboarding();
                          },
                          child: Text(
                            'Skip',
                            style: TextStyle(
                              color: scheme.onSurfaceVariant,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        )
                      else
                        const SizedBox(width: 48),
                    ],
                  ),
                ),

                // Page views for steps
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _buildWelcomeStep(context, state, cubit),
                      _buildHowItWorksStep(context, state),
                      _buildDietaryStep(context, state, cubit),
                      _buildCuisinesStep(context, state, cubit),
                      _buildCookingSkillStep(context, state, cubit),
                      _buildCookingTimeStep(context, state, cubit),
                      _buildGoalsStep(context, state, cubit),
                      _buildNotificationsStep(context, state, cubit),
                      _buildCompleteStep(context, state, cubit),
                    ],
                  ),
                ),

                // Bottom action CTA
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.sm,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  child: AppButton(
                    label: state.isLastStep
                        ? "Let's Cook! 🍳"
                        : (state.currentStep == 7
                              ? (state.preferences.notificationsEnabled
                                    ? "Enable & Continue 🔔"
                                    : "Continue →")
                              : (state.isFirstStep
                                    ? "Get Started ✨"
                                    : "Continue →")),
                    backgroundColor: isDark
                        ? AppColors.butterGold
                        : AppColors.primaryGold,
                    foregroundColor: const Color(0xFF141414),
                    isLoading: state.status == OnboardingStatus.completing,
                    onPressed: () async {
                      if (state.isFirstStep) {
                        cubit.updateName(_nameController.text);
                      }
                      if (state.currentStep == 7 &&
                          state.preferences.notificationsEnabled) {
                        await cubit.requestNotificationPermission();
                      }
                      if (state.isLastStep) {
                        await cubit.completeOnboarding();
                      } else {
                        cubit.nextStep();
                        _goToPage(state.currentStep + 1);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWelcomeStep(
    BuildContext context,
    OnboardingState state,
    OnboardingCubit cubit,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.sm),
          // Culinary Hero Avatar / Badge
          Container(
            width: 124,
            height: 124,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.butterGold : AppColors.primaryGold,
                width: 3.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? AppColors.butterGold : AppColors.primaryGold)
                      .withValues(alpha: isDark ? 0.35 : 0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              image: const DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&q=80',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'AnuMealAI',
            style: textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: scheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your mood. Your ingredients. Your perfect meal.',
            textAlign: TextAlign.center,
            style: textTheme.titleMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_rounded,
                        size: 18,
                        color: isDark
                            ? scheme.onPrimaryContainer
                            : AppColors.onAmberContainer,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'What should we call you?',
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                AppTextField(
                  hintText: 'Enter your name (e.g. Anu)...',
                  controller: _nameController,
                  prefixIcon: Icons.edit_outlined,
                  onChanged: (val) => cubit.updateName(val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksStep(BuildContext context, OnboardingState state) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How AnuMealAI works',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            '3 simple steps to eliminate mealtime stress.',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildInfoRow(
            context,
            stepTag: 'Step 01',
            emoji: '😌',
            iconBg: AppColors.amberContainer,
            title: 'Tell us your mood',
            subtitle:
                'Stressed, lazy, happy, or energetic — your mood shapes what sounds delicious.',
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(
            context,
            stepTag: 'Step 02',
            emoji: '🍅',
            iconBg: AppColors.terracottaLight,
            title: 'Check your ingredients',
            subtitle:
                'Pick what is already sitting in your fridge and pantry so nothing goes to waste.',
          ),
          const SizedBox(height: AppSpacing.md),
          _buildInfoRow(
            context,
            stepTag: 'Step 03',
            emoji: '✨',
            iconBg: AppColors.sageLight,
            title: 'Cook your perfect meal',
            subtitle:
                'Instant AI recommendations with exact match scores and step-by-step guidance.',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String stepTag,
    required String emoji,
    required Color iconBg,
    required String title,
    required String subtitle,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: isDark ? scheme.surfaceContainerHighest : iconBg,
              shape: BoxShape.circle,
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    stepTag,
                    style: TextStyle(
                      color: isDark
                          ? scheme.onPrimaryContainer
                          : AppColors.onAmberContainer,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDietaryStep(
    BuildContext context,
    OnboardingState state,
    OnboardingCubit cubit,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final options = [
      ('Vegetarian', '🥗'),
      ('Vegan', '🌱'),
      ('Keto', '🥑'),
      ('Pescatarian', '🐟'),
      ('Gluten-Free', '🌾'),
      ('Dairy-Free', '🥛'),
      ('Low-Carb', '🥦'),
      ('Nut-Free', '🥜'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dietary Preferences',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Select any dietary restrictions or lifestyle preferences.',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.3,
            ),
            itemCount: options.length,
            itemBuilder: (context, index) {
              final opt = options[index];
              final isSelected = state.preferences.dietaryRestrictions.contains(
                opt.$1,
              );
              return _buildGridOption(
                context: context,
                emoji: opt.$2,
                title: opt.$1,
                isSelected: isSelected,
                onTap: () => cubit.toggleDietary(opt.$1),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCuisinesStep(
    BuildContext context,
    OnboardingState state,
    OnboardingCubit cubit,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final cuisines = [
      ('Italian', '🍝'),
      ('Mexican', '🌮'),
      ('Asian', '🥢'),
      ('Indian', '🍛'),
      ('Mediterranean', '🫒'),
      ('American', '🍔'),
      ('Japanese', '🍱'),
      ('Thai', '🍲'),
      ('Middle Eastern', '🧆'),
      ('French', '🥐'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Favorite Cuisines',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Pick the cuisines you enjoy the most.',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.3,
            ),
            itemCount: cuisines.length,
            itemBuilder: (context, index) {
              final c = cuisines[index];
              final isSelected = state.preferences.favoriteCuisines.any(
                (fav) => fav.contains(c.$1),
              );
              return _buildGridOption(
                context: context,
                emoji: c.$2,
                title: c.$1,
                isSelected: isSelected,
                onTap: () => cubit.toggleCuisine(c.$1),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCookingSkillStep(
    BuildContext context,
    OnboardingState state,
    OnboardingCubit cubit,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final skills = [
      (
        'Beginner',
        '🌱',
        'Simple recipes with minimal equipment and quick steps.',
        'Quick & Simple',
        AppColors.sageLight,
      ),
      (
        'Intermediate',
        '🍳',
        'Comfortable with everyday kitchen techniques & seasoning.',
        'Home Cook',
        AppColors.amberContainer,
      ),
      (
        'Advanced',
        '👨‍🍳',
        'Enjoys complex techniques, layering flavors, and baking.',
        'Culinary Pro',
        AppColors.terracottaLight,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cooking Experience',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'How comfortable are you in the kitchen?',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...skills.map((s) {
            final isSelected = state.preferences.cookingSkill == s.$1;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => cubit.setCookingSkill(s.$1),
                  borderRadius: BorderRadius.circular(24),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                                ? const Color(0xFF2C2614)
                                : scheme.primaryContainer.withValues(
                                    alpha: 0.35,
                                  ))
                          : (isDark
                                ? scheme.surfaceContainerHigh
                                : Colors.white),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? scheme.primary
                            : (isDark
                                  ? const Color(0xFF2E2E2E)
                                  : scheme.outlineVariant),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? scheme.primary.withValues(
                                  alpha: isDark ? 0.3 : 0.15,
                                )
                              : Colors.black.withValues(
                                  alpha: isDark ? 0.2 : 0.03,
                                ),
                          blurRadius: isSelected ? 10 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isDark
                                ? scheme.surfaceContainerHighest
                                : s.$5,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              s.$2,
                              style: const TextStyle(fontSize: 26),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    s.$1,
                                    style: textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: scheme.surfaceContainerHighest,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      s.$4,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: scheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                s.$3,
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  height: 1.3,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            size: 24,
                            color: isDark
                                ? AppColors.butterGold
                                : AppColors.primaryGold,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCookingTimeStep(
    BuildContext context,
    OnboardingState state,
    OnboardingCubit cubit,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final times = [
      (
        15,
        '⚡ 15 MIN',
        'Quick & Easy',
        'Fast, delicious meals for busy weekdays.',
      ),
      (
        30,
        '⏱️ 30 MIN',
        'Balanced Daily',
        'Solid homemade dinners with rich flavor.',
      ),
      (
        45,
        '🥘 45 MIN',
        'Hearty & Slow',
        'Flavorsome, simmered & roasted comfort food.',
      ),
      (
        60,
        '🍷 60+ MIN',
        'Leisurely Gourmet',
        'Weekend culinary adventures & baking.',
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Typical Cooking Time',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'How much time do you usually want to spend cooking?',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...times.map((t) {
            final isSelected =
                state.preferences.typicalCookingTimeMinutes == t.$1;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => cubit.setTypicalTime(t.$1),
                  borderRadius: BorderRadius.circular(24),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? (isDark
                                ? const Color(0xFF2C2614)
                                : scheme.primaryContainer.withValues(
                                    alpha: 0.35,
                                  ))
                          : (isDark
                                ? scheme.surfaceContainerHigh
                                : Colors.white),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isSelected
                            ? scheme.primary
                            : (isDark
                                  ? const Color(0xFF2E2E2E)
                                  : scheme.outlineVariant),
                        width: isSelected ? 2.0 : 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected
                              ? scheme.primary.withValues(
                                  alpha: isDark ? 0.3 : 0.15,
                                )
                              : Colors.black.withValues(
                                  alpha: isDark ? 0.2 : 0.03,
                                ),
                          blurRadius: isSelected ? 10 : 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark
                                      ? AppColors.butterGold
                                      : AppColors.primaryGold)
                                : scheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusPill,
                            ),
                          ),
                          child: Text(
                            t.$2,
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF141414)
                                  : scheme.onSurfaceVariant,
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t.$3,
                                style: textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                t.$4,
                                style: textTheme.bodySmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 12.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle_rounded,
                            size: 22,
                            color: isDark
                                ? AppColors.butterGold
                                : AppColors.primaryGold,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGoalsStep(
    BuildContext context,
    OnboardingState state,
    OnboardingCubit cubit,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final goals = [
      ('Quick weeknight dinners', '⏱️'),
      ('Reduce food waste', '🥦'),
      ('Eat healthier meals', '🥗'),
      ('Save money on groceries', '💰'),
      ('Learn exciting recipes', '👨‍🍳'),
      ('Stress-free meal planning', '📅'),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Goals',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'What are you looking to achieve with AnuMealAI?',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          ...goals.map((g) {
            final isSelected = state.preferences.mealGoals.any(
              (goal) => goal.startsWith(g.$1),
            );
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: _buildListOption(
                context: context,
                emoji: g.$2,
                title: g.$1,
                isSelected: isSelected,
                onTap: () => cubit.toggleGoal(g.$1),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildNotificationsStep(
    BuildContext context,
    OnboardingState state,
    OnboardingCubit cubit,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Stay Inspired',
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Gentle, smart meal ideas tailored to what is in your fridge.',
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Live Push Notification Preview Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF28241A), const Color(0xFF1E1E1E)]
                    : [const Color(0xFFFFFBEB), Colors.white],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF38301B)
                    : AppColors.amberContainer,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: isDark ? 0.2 : 0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.butterGold
                            : AppColors.primaryGold,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.restaurant_menu_rounded,
                        size: 14,
                        color: Color(0xFF141414),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'ANUMEALAI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.8,
                        color: isDark
                            ? AppColors.butterGold
                            : AppColors.primaryGoldDark,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '5:00 PM',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '🍳 Dinner inspiration ready!',
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'You have tomatoes, pasta & olive oil — make Quick Tomato Basil Pasta in 20 min.',
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Interactive Toggle Card
          AppCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: isDark
                  ? AppColors.butterGold
                  : AppColors.primaryGold,
              title: Text(
                'Daily Meal Notification',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              subtitle: Text(
                'Receive a friendly dinner idea every evening before dinner time.',
                style: textTheme.bodySmall?.copyWith(
                  color: scheme.onSurfaceVariant,
                  height: 1.3,
                ),
              ),
              value: state.preferences.notificationsEnabled,
              onChanged: (val) async {
                if (val) {
                  await cubit.requestNotificationPermission();
                } else {
                  cubit.setNotificationsEnabled(false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompleteStep(
    BuildContext context,
    OnboardingState state,
    OnboardingCubit cubit,
  ) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final prefs = state.preferences;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: AppSpacing.md),

          // Glowing Celebration Hero Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: const RadialGradient(
                colors: [Color(0xFFFEF3C7), Color(0xFFFDE68A)],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: isDark ? AppColors.butterGold : AppColors.primaryGold,
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? AppColors.butterGold : AppColors.primaryGold)
                      .withValues(alpha: isDark ? 0.35 : 0.25),
                  blurRadius: 24,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Text('🎉', style: TextStyle(fontSize: 48)),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          Text(
            "You're all set, ${prefs.name.isNotEmpty ? prefs.name : 'Anu'}!",
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
              fontSize: 24,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your personalized AI kitchen is ready to turn everyday ingredients into culinary magic.',
            textAlign: TextAlign.center,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
              height: 1.35,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Kitchen Setup Overview Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isDark ? scheme.surfaceContainerHigh : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isDark ? const Color(0xFF2E2E2E) : scheme.outlineVariant,
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: scheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: const Text('✨', style: TextStyle(fontSize: 18)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Kitchen Profile',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Preferences & Taste Customization',
                            style: textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.butterGold.withValues(alpha: 0.15)
                            : AppColors.amberContainer,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusPill,
                        ),
                      ),
                      child: Text(
                        'READY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.6,
                          color: isDark
                              ? AppColors.butterGold
                              : AppColors.onAmberContainer,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),

                _buildSummaryTile(
                  context,
                  emoji: '👨‍🍳',
                  label: 'Experience',
                  value: prefs.cookingSkill,
                ),
                const SizedBox(height: 12),
                _buildSummaryTile(
                  context,
                  emoji: '⏱️',
                  label: 'Cooking Time',
                  value: '${prefs.typicalCookingTimeMinutes} min daily target',
                ),
                const SizedBox(height: 12),
                _buildSummaryTile(
                  context,
                  emoji: '🍝',
                  label: 'Cuisines',
                  value: prefs.favoriteCuisines.isEmpty
                      ? 'All Cuisines'
                      : prefs.favoriteCuisines.join(', '),
                ),
                const SizedBox(height: 12),
                _buildSummaryTile(
                  context,
                  emoji: '🥗',
                  label: 'Dietary',
                  value: prefs.dietaryRestrictions.isEmpty
                      ? 'No restrictions'
                      : prefs.dietaryRestrictions.join(', '),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // Match Highlights Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF242013)
                  : scheme.primaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark
                    ? const Color(0xFF38301B)
                    : AppColors.amberContainer,
                width: 1.0,
              ),
            ),
            child: Row(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 22)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '28+ custom recipe matches waiting for your first cook!',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? scheme.onPrimaryContainer
                          : AppColors.onAmberContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryTile(
    BuildContext context, {
    required String emoji,
    required String label,
    required String value,
  }) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 10),
        Text(
          label,
          style: textTheme.bodyMedium?.copyWith(
            color: scheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: scheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridOption({
    required BuildContext context,
    required String emoji,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF2C2614) : scheme.primaryContainer)
                : (isDark ? scheme.surfaceContainerHigh : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? scheme.primary
                  : (isDark ? const Color(0xFF2E2E2E) : scheme.outlineVariant),
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? scheme.primary.withValues(alpha: isDark ? 0.25 : 0.15)
                    : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected
                        ? (isDark
                              ? scheme.onPrimaryContainer
                              : AppColors.onAmberContainer)
                        : scheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: isDark ? AppColors.butterGold : AppColors.primaryGold,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListOption({
    required BuildContext context,
    required String emoji,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark
                      ? const Color(0xFF2C2614)
                      : scheme.primaryContainer.withValues(alpha: 0.35))
                : (isDark ? scheme.surfaceContainerHigh : Colors.white),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? scheme.primary
                  : (isDark ? const Color(0xFF2E2E2E) : scheme.outlineVariant),
              width: isSelected ? 1.8 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? scheme.primary.withValues(alpha: isDark ? 0.25 : 0.15)
                    : Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
                blurRadius: isSelected ? 8 : 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: isSelected
                        ? (isDark
                              ? scheme.onPrimaryContainer
                              : const Color(0xFF141414))
                        : scheme.onSurface,
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    fontSize: 14.5,
                  ),
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle_rounded,
                  size: 20,
                  color: isDark ? AppColors.butterGold : AppColors.primaryGold,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
