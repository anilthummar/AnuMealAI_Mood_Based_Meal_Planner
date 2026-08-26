import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:anu_meal_ai/core/theme/app_theme.dart';
import 'package:anu_meal_ai/core/widgets/app_button.dart';
import 'package:anu_meal_ai/core/widgets/empty_state.dart';
import 'package:anu_meal_ai/core/widgets/ingredient_chip.dart';
import 'package:anu_meal_ai/core/widgets/mood_card.dart';

void main() {
  group('UI Components Smoke Tests', () {
    testWidgets('AppButton renders label and triggers tap', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: AppButton(
              label: 'Generate Recipe',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Generate Recipe'), findsOneWidget);
      await tester.tap(find.byType(AppButton));
      expect(tapped, isTrue);
    });

    testWidgets('MoodCard renders emoji, title and triggers selection', (tester) async {
      bool selected = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: MoodCard(
              emoji: '😊',
              name: 'Happy',
              description: 'Feeling great',
              isSelected: false,
              onTap: () => selected = true,
            ),
          ),
        ),
      );

      expect(find.text('Happy'), findsOneWidget);
      expect(find.text('😊'), findsOneWidget);
      await tester.tap(find.byType(MoodCard));
      expect(selected, isTrue);
    });

    testWidgets('IngredientChip renders label and quantity', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: const Scaffold(
            body: IngredientChip(
              label: 'Tomatoes',
              quantity: '3 pcs',
            ),
          ),
        ),
      );

      expect(find.text('Tomatoes'), findsOneWidget);
      expect(find.text('(3 pcs)'), findsOneWidget);
    });

    testWidgets('EmptyState displays friendly copy and CTA', (tester) async {
      bool ctaPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: EmptyState(
              emoji: '🥗',
              title: 'Nothing here yet',
              message: 'Add some items to get started',
              actionLabel: 'Add Items',
              onAction: () => ctaPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Nothing here yet'), findsOneWidget);
      expect(find.text('Add Items'), findsOneWidget);
      await tester.tap(find.text('Add Items'));
      expect(ctaPressed, isTrue);
    });
  });
}
