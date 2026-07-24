import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tick_notes/core/database/app_database.dart';
import 'package:tick_notes/core/notifications/notification_service.dart';
import 'package:tick_notes/features/todo/todo_repository.dart';
import 'package:tick_notes/features/todo/todo_view_model.dart';

// ── Mocks ──────────────────────────────────────────────────────────────
class MockTodoRepository extends Mock implements TodoRepository {}

class MockNotificationService extends Mock implements NotificationService {}

// ── Fallback values ─────────────────────────────────────────────────
class FakeTodosCompanion extends Fake implements TodosCompanion {}

void main() {
  late MockTodoRepository mockRepo;
  late MockNotificationService mockNotifications;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(FakeTodosCompanion());
  });

  setUp(() {
    mockRepo = MockTodoRepository();
    mockNotifications = MockNotificationService();

    container = ProviderContainer(
      overrides: [
        todoRepositoryProvider.overrideWithValue(mockRepo),
        notificationServiceProvider.overrideWithValue(mockNotifications),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('TodoViewModel', () {
    test('build() calls watchAll() on repository', () {
      // Arrange
      when(() => mockRepo.watchAll())
          .thenAnswer((_) => Stream.value([]));

      // Act
      final sub = container.listen(todoViewModelProvider, (p, n) {});

      // Assert
      verify(() => mockRepo.watchAll()).called(1);
      sub.close();
    });

    test('addTodo without reminder does NOT schedule a notification', () async {
      // Arrange
      when(() => mockRepo.watchAll())
          .thenAnswer((_) => Stream.value([]));
      when(() => mockRepo.add(any())).thenAnswer((_) async => 1);

      // Act
      container.listen(todoViewModelProvider, (p, n) {});
      final id = await container
          .read(todoViewModelProvider.notifier)
          .addTodo(
            title: 'No Reminder Task',
            dueDate: null,
            colorTag: 0,
            hasReminder: false,
            hasAlarm: false,
            alarmSound: 'default',
          );

      // Assert
      expect(id, equals(1));
      verify(() => mockRepo.add(any())).called(1);
      verifyNever(
        () => mockNotifications.scheduleNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledTime: any(named: 'scheduledTime'),
        ),
      );
    });

    test('addTodo with reminder schedules a notification', () async {
      // Arrange
      final futureDate = DateTime.now().add(const Duration(hours: 2));
      when(() => mockRepo.watchAll())
          .thenAnswer((_) => Stream.value([]));
      when(() => mockRepo.add(any())).thenAnswer((_) async => 10);
      when(() => mockNotifications.requestPermissions())
          .thenAnswer((_) async => true);
      when(
        () => mockNotifications.scheduleNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledTime: any(named: 'scheduledTime'),
        ),
      ).thenAnswer((_) async {});

      // Act
      container.listen(todoViewModelProvider, (p, n) {});
      final id = await container
          .read(todoViewModelProvider.notifier)
          .addTodo(
            title: 'Reminder Task',
            dueDate: futureDate,
            colorTag: 1,
            hasReminder: true,
            hasAlarm: true,
            alarmSound: 'default',
          );

      // Assert
      expect(id, equals(10));
      verify(() => mockRepo.add(any())).called(1);
      verify(() => mockNotifications.requestPermissions()).called(1);
      verify(
        () => mockNotifications.scheduleNotification(
          id: 10,
          title: 'Task Reminder',
          body: 'Reminder Task',
          scheduledTime: futureDate,
        ),
      ).called(1);
    });

    test('toggleComplete marks incomplete todo as complete and cancels notification',
        () async {
      // Arrange
      final testTodo = Todo(
        id: 5,
        title: 'Finish tests',
        dueDate: DateTime.now().add(const Duration(days: 1)),
        isCompleted: false,
        colorTag: 0,
        hasAlarm: false,
        alarmSound: 'default',
        updatedAt: DateTime.now(),
      );

      when(() => mockRepo.watchAll())
          .thenAnswer((_) => Stream.value([]));
      when(() => mockRepo.updateTodo(any(), any()))
          .thenAnswer((_) async {});
      when(() => mockNotifications.cancelNotification(any()))
          .thenAnswer((_) async {});

      // Act
      container.listen(todoViewModelProvider, (p, n) {});
      await container
          .read(todoViewModelProvider.notifier)
          .toggleComplete(testTodo);

      // Assert — should update with isCompleted = true
      final captured =
          verify(() => mockRepo.updateTodo(5, captureAny())).captured;
      expect(captured.length, 1);
      final companion = captured.first as TodosCompanion;
      expect(companion.isCompleted.value, isTrue);

      // Should cancel the notification for the completed todo
      verify(() => mockNotifications.cancelNotification(5)).called(1);
    });

    test('deleteTodo deletes from repo and cancels notification', () async {
      // Arrange
      when(() => mockRepo.watchAll())
          .thenAnswer((_) => Stream.value([]));
      when(() => mockRepo.delete(any())).thenAnswer((_) async {});
      when(() => mockNotifications.cancelNotification(any()))
          .thenAnswer((_) async {});

      // Act
      container.listen(todoViewModelProvider, (p, n) {});
      await container
          .read(todoViewModelProvider.notifier)
          .deleteTodo(3);

      // Assert
      verify(() => mockRepo.delete(3)).called(1);
      verify(() => mockNotifications.cancelNotification(3)).called(1);
    });
  });
}
