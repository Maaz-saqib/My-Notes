import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tick_notes/core/database/app_database.dart';
import 'package:tick_notes/features/notes/notes_repository.dart';
import 'package:tick_notes/features/notes/notes_view_model.dart';

// ── Mocks ──────────────────────────────────────────────────────────────
class MockNotesRepository extends Mock implements NotesRepository {}

// ── Fallback values for mocktail ─────────────────────────────────────
class FakeNotesCompanion extends Fake implements NotesCompanion {}

void main() {
  late MockNotesRepository mockRepo;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(FakeNotesCompanion());
  });

  setUp(() {
    mockRepo = MockNotesRepository();

    container = ProviderContainer(
      overrides: [
        notesRepositoryProvider.overrideWithValue(mockRepo),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('NotesViewModel', () {
    test('build() calls watchAll() and returns stream of notes', () {
      // Arrange
      final testNotes = [
        Note(
          id: 1,
          title: 'Test Note',
          body: 'Test Body',
          colorTag: 0,
          isList: false,
          updatedAt: DateTime.now(),
        ),
      ];
      when(() => mockRepo.watchAll())
          .thenAnswer((_) => Stream.value(testNotes));

      // Act - reading the provider triggers build()
      final subscription = container.listen(
        notesViewModelProvider,
        (p, n) {},
      );

      // Assert
      verify(() => mockRepo.watchAll()).called(1);
      subscription.close();
    });

    test('addNote() calls repository.add() with correct companion', () async {
      // Arrange
      when(() => mockRepo.watchAll())
          .thenAnswer((_) => Stream.value([]));
      when(() => mockRepo.add(any())).thenAnswer((_) async => 42);

      // Act - trigger build first so the notifier is alive
      container.listen(notesViewModelProvider, (p, n) {});
      final result = await container
          .read(notesViewModelProvider.notifier)
          .addNote('My Title', 'My Body', 2);

      // Assert
      expect(result, equals(42));

      final captured = verify(() => mockRepo.add(captureAny())).captured;
      expect(captured.length, 1);
      final companion = captured.first as NotesCompanion;
      expect(companion.title.value, equals('My Title'));
      expect(companion.body.value, equals('My Body'));
      expect(companion.colorTag.value, equals(2));
    });

    test('deleteNote() calls repository.delete() with correct id', () async {
      // Arrange
      when(() => mockRepo.watchAll())
          .thenAnswer((_) => Stream.value([]));
      when(() => mockRepo.delete(any())).thenAnswer((_) async {});

      // Act
      container.listen(notesViewModelProvider, (p, n) {});
      await container
          .read(notesViewModelProvider.notifier)
          .deleteNote(7);

      // Assert
      verify(() => mockRepo.delete(7)).called(1);
    });

    test('getNoteById() calls repository.getNote() with correct id', () async {
      // Arrange
      final testNote = Note(
        id: 5,
        title: 'Found',
        body: 'Body',
        colorTag: 1,
        isList: false,
        updatedAt: DateTime.now(),
      );
      when(() => mockRepo.watchAll())
          .thenAnswer((_) => Stream.value([]));
      when(() => mockRepo.getNote(any()))
          .thenAnswer((_) async => testNote);

      // Act
      container.listen(notesViewModelProvider, (p, n) {});
      final result = await container
          .read(notesViewModelProvider.notifier)
          .getNoteById(5);

      // Assert
      expect(result, equals(testNote));
      verify(() => mockRepo.getNote(5)).called(1);
    });
  });
}
