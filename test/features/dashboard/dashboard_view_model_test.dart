import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:tick_notes/core/database/app_database.dart';
import 'package:tick_notes/features/notes/notes_repository.dart';
import 'package:tick_notes/features/todo/todo_repository.dart';
import 'package:tick_notes/features/dashboard/dashboard_view_model.dart';

// ── Mocks ──────────────────────────────────────────────────────────────
class MockNotesRepository extends Mock implements NotesRepository {}

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late MockNotesRepository mockNotesRepo;
  late MockTodoRepository mockTodoRepo;
  late ProviderContainer container;

  setUp(() {
    mockNotesRepo = MockNotesRepository();
    mockTodoRepo = MockTodoRepository();

    container = ProviderContainer(
      overrides: [
        notesRepositoryProvider.overrideWithValue(mockNotesRepo),
        todoRepositoryProvider.overrideWithValue(mockTodoRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('DashboardViewModel - shouldShowOnboarding', () {
    test('returns true when no data exists and onboarding not seen', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      when(() => mockNotesRepo.getAll()).thenAnswer((_) async => []);
      when(() => mockTodoRepo.getAll()).thenAnswer((_) async => []);

      // Act
      container.read(dashboardViewModelProvider); // trigger build
      final result = await container
          .read(dashboardViewModelProvider.notifier)
          .shouldShowOnboarding();

      // Assert
      expect(result, isTrue);
      verify(() => mockNotesRepo.getAll()).called(1);
      verify(() => mockTodoRepo.getAll()).called(1);
    });

    test(
        'returns false and marks onboarding complete when notes data exists',
        () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      final testNote = Note(
        id: 1,
        title: 'Existing Note',
        body: 'Content',
        colorTag: 0,
        isList: false,
        updatedAt: DateTime.now(),
      );
      when(() => mockNotesRepo.getAll())
          .thenAnswer((_) async => [testNote]);
      when(() => mockTodoRepo.getAll()).thenAnswer((_) async => []);

      // Act
      container.read(dashboardViewModelProvider);
      final result = await container
          .read(dashboardViewModelProvider.notifier)
          .shouldShowOnboarding();

      // Assert
      expect(result, isFalse);

      // Verify it wrote 'onboarding_complete' = true to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboarding_complete'), isTrue);
    });

    test(
        'returns false and marks onboarding complete when todos data exists',
        () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});
      final testTodo = Todo(
        id: 1,
        title: 'Existing Todo',
        dueDate: null,
        isCompleted: false,
        colorTag: 0,
        updatedAt: DateTime.now(),
      );
      when(() => mockNotesRepo.getAll()).thenAnswer((_) async => []);
      when(() => mockTodoRepo.getAll())
          .thenAnswer((_) async => [testTodo]);

      // Act
      container.read(dashboardViewModelProvider);
      final result = await container
          .read(dashboardViewModelProvider.notifier)
          .shouldShowOnboarding();

      // Assert
      expect(result, isFalse);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboarding_complete'), isTrue);
    });

    test(
        'returns false without calling repos when onboarding_complete is already true',
        () async {
      // Arrange
      SharedPreferences.setMockInitialValues({'onboarding_complete': true});

      // Act
      container.read(dashboardViewModelProvider);
      final result = await container
          .read(dashboardViewModelProvider.notifier)
          .shouldShowOnboarding();

      // Assert
      expect(result, isFalse);

      // Repos should NEVER be called — early return from SharedPreferences check
      verifyNever(() => mockNotesRepo.getAll());
      verifyNever(() => mockTodoRepo.getAll());
    });
  });

  group('DashboardViewModel - markOnboardingComplete', () {
    test('writes onboarding_complete = true to SharedPreferences', () async {
      // Arrange
      SharedPreferences.setMockInitialValues({});

      // Act
      container.read(dashboardViewModelProvider);
      await container
          .read(dashboardViewModelProvider.notifier)
          .markOnboardingComplete();

      // Assert
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('onboarding_complete'), isTrue);
    });
  });
}
