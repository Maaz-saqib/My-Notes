import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tick_notes/core/database/app_database.dart';
import 'package:tick_notes/core/theme/theme_notifier.dart';
import 'package:tick_notes/features/notes/notes_list_screen.dart';
import 'package:tick_notes/features/notes/notes_view_model.dart';

// Mock NotesViewModel
class MockNotesViewModel extends AutoDisposeStreamNotifier<List<Note>>
    with Mock
    implements NotesViewModel {
  final Stream<List<Note>> _stream;
  MockNotesViewModel(this._stream);

  @override
  Stream<List<Note>> build() => _stream;
}

// Mock ThemeNotifier
class MockThemeNotifier extends AutoDisposeNotifier<ThemeSettingsState>
    with Mock
    implements ThemeNotifier {
  @override
  ThemeSettingsState build() {
    return const ThemeSettingsState(
      themeMode: ThemeMode.light,
      seedColor: Colors.blue,
    );
  }
}

void main() {
  group('NotesListScreen Widget Tests', () {
    late MockThemeNotifier mockThemeNotifier;

    setUp(() {
      mockThemeNotifier = MockThemeNotifier();
    });

    Widget buildTestWidget(MockNotesViewModel mockNotesViewModel) {
      return ProviderScope(
        overrides: [
          notesViewModelProvider.overrideWith(() => mockNotesViewModel),
          themeNotifierProvider.overrideWith(() => mockThemeNotifier),
        ],
        child: const MaterialApp(
          home: NotesListScreen(),
        ),
      );
    }

    testWidgets('Empty State - shows empty state illustration and message', (WidgetTester tester) async {
      final mockNotesViewModel = MockNotesViewModel(Stream.value(<Note>[]));

      await tester.pumpWidget(buildTestWidget(mockNotesViewModel));
      await tester.pumpAndSettle();

      // Verify empty state messages render
      expect(find.text('No notes yet'), findsOneWidget);
      expect(
        find.text('Tap the "+" icon in the top right to create your first note.'),
        findsOneWidget,
      );
    });

    testWidgets('Populated State - shows list of notes', (WidgetTester tester) async {
      final note = Note(
        id: 1,
        title: 'Groceries',
        body: 'Milk',
        colorTag: 0,
        isList: false,
        updatedAt: DateTime.now(),
      );
      final mockNotesViewModel = MockNotesViewModel(Stream.value([note]));

      await tester.pumpWidget(buildTestWidget(mockNotesViewModel));
      await tester.pumpAndSettle();

      // Verify note title and body render in the list
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Milk'), findsOneWidget);
      
      // Verify empty state is NOT showing
      expect(find.text('No notes yet'), findsNothing);
    });
  });
}
