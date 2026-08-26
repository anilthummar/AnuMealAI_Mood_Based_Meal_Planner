import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:anu_meal_ai/core/services/analytics_service.dart';
import 'package:anu_meal_ai/features/shopping_list/domain/entities/shopping_item.dart';
import 'package:anu_meal_ai/features/shopping_list/domain/repositories/shopping_list_repository.dart';
import 'package:anu_meal_ai/features/shopping_list/presentation/bloc/shopping_list_cubit.dart';

class MockShoppingListRepository extends Mock implements ShoppingListRepository {}
class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  setUpAll(() {
    registerFallbackValue(
      ShoppingItem(
        id: 'test-id',
        name: 'Test Item',
        category: 'Produce',
        createdAt: DateTime.now(),
      ),
    );
  });

  group('ShoppingListCubit', () {
    late MockShoppingListRepository mockRepo;
    late MockAnalyticsService mockAnalytics;
    late ShoppingListCubit cubit;

    setUp(() {
      mockRepo = MockShoppingListRepository();
      mockAnalytics = MockAnalyticsService();

      when(() => mockRepo.itemsStream).thenAnswer((_) => Stream.value([]));
      when(() => mockRepo.getItems()).thenAnswer((_) async => []);
      when(() => mockRepo.addItem(any())).thenAnswer((_) async {});
      when(() => mockAnalytics.logShoppingItemAdded(any())).thenAnswer((_) async {});

      cubit = ShoppingListCubit(
        shoppingListRepository: mockRepo,
        analytics: mockAnalytics,
      );
    });

    tearDown(() {
      cubit.close();
    });

    test('addItem creates and stores shopping item correctly', () async {
      await cubit.addItem(name: 'Fresh Basil', category: 'Produce', quantity: '2 bunches');

      verify(() => mockRepo.addItem(any(that: isA<ShoppingItem>().having((i) => i.name, 'name', 'Fresh Basil')))).called(1);
      verify(() => mockAnalytics.logShoppingItemAdded('Fresh Basil')).called(1);
    });

    test('toggleCheck delegates to repository', () async {
      when(() => mockRepo.toggleCheck('item-123')).thenAnswer((_) async {});

      await cubit.toggleCheck('item-123');
      verify(() => mockRepo.toggleCheck('item-123')).called(1);
    });

    test('clearCompleted delegates to repository', () async {
      when(() => mockRepo.clearCompleted()).thenAnswer((_) async {});

      await cubit.clearCompleted();
      verify(() => mockRepo.clearCompleted()).called(1);
    });
  });
}
