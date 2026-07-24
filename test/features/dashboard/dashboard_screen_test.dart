import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:tick_notes/core/database/app_database.dart';
import 'package:tick_notes/core/theme/theme_notifier.dart';
import 'package:tick_notes/features/dashboard/dashboard_screen.dart';
import 'package:tick_notes/features/dashboard/dashboard_view_model.dart';
import 'package:tick_notes/features/notes/notes_view_model.dart';
import 'package:tick_notes/features/todo/todo_view_model.dart';
import 'package:tick_notes/features/pomodoro/pomodoro_view_model.dart';
import 'package:tick_notes/features/analytics/analytics_view_model.dart';

// 1. Mock DashboardViewModel
class MockDashboardViewModel extends AutoDisposeNotifier<void>
    with Mock
    implements DashboardViewModel {
  @override
  void build() {}

  @override
  Future<bool> shouldShowOnboarding() async => false;
}

// 2. Mock NotesViewModel
class MockNotesViewModel extends AutoDisposeStreamNotifier<List<Note>>
    with Mock
    implements NotesViewModel {
  final Stream<List<Note>> _stream;
  MockNotesViewModel(this._stream);

  @override
  Stream<List<Note>> build() => _stream;
}

// 3. Mock TodoViewModel
class MockTodoViewModel extends AutoDisposeStreamNotifier<List<Todo>>
    with Mock
    implements TodoViewModel {
  final Stream<List<Todo>> _stream;
  MockTodoViewModel(this._stream);

  @override
  Stream<List<Todo>> build() => _stream;
}

// 4. Mock PomodoroViewModel
class MockPomodoroViewModel extends Notifier<PomodoroState>
    with Mock
    implements PomodoroViewModel {
  @override
  PomodoroState build() {
    return const PomodoroState(
      mode: FocusMode.pomodoro,
      pomodoroPhase: PomodoroPhase.focus,
      pomodoroSession: 1,
      isRunning: false,
      durationLimit: Duration(minutes: 25),
      elapsedDuration: Duration.zero,
    );
  }

  @override
  int get customFocusMins => 25;

  @override
  int get customBreakMins => 5;
}

// 5. Mock AnalyticsViewModel
class MockAnalyticsViewModel extends AutoDisposeStreamNotifier<List<DailyFocusStats>>
    with Mock
    implements AnalyticsViewModel {
  final Stream<List<DailyFocusStats>> _stream;
  MockAnalyticsViewModel(this._stream);

  @override
  Stream<List<DailyFocusStats>> build() => _stream;
}

// 6. Mock ThemeNotifier
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
  group('DashboardScreen Widget Tests', () {
    late MockDashboardViewModel mockDashboardViewModel;
    late MockNotesViewModel mockNotesViewModel;
    late MockTodoViewModel mockTodoViewModel;
    late MockPomodoroViewModel mockPomodoroViewModel;
    late MockAnalyticsViewModel mockAnalyticsViewModel;
    late MockThemeNotifier mockThemeNotifier;

    setUp(() {
      mockDashboardViewModel = MockDashboardViewModel();
      mockNotesViewModel = MockNotesViewModel(Stream.value(<Note>[]));
      mockTodoViewModel = MockTodoViewModel(Stream.value(<Todo>[]));
      mockPomodoroViewModel = MockPomodoroViewModel();
      mockAnalyticsViewModel = MockAnalyticsViewModel(Stream.value(<DailyFocusStats>[]));
      mockThemeNotifier = MockThemeNotifier();
    });

    Widget buildTestWidget() {
      return ProviderScope(
        overrides: [
          dashboardViewModelProvider.overrideWith(() => mockDashboardViewModel),
          notesViewModelProvider.overrideWith(() => mockNotesViewModel),
          todoViewModelProvider.overrideWith(() => mockTodoViewModel),
          pomodoroViewModelProvider.overrideWith(() => mockPomodoroViewModel),
          analyticsViewModelProvider.overrideWith(() => mockAnalyticsViewModel),
          themeNotifierProvider.overrideWith(() => mockThemeNotifier),
        ],
        child: const MaterialApp(
          home: DashboardScreen(),
        ),
      );
    }

    testWidgets('Initial Tab - NotesListScreen shows first', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Verify that 'Your Notes' AppBar text is visible (Notes list screen)
      expect(find.text('Your Notes'), findsOneWidget);
      // Verify 'Tasks & Reminders' is not visible
      expect(find.text('Tasks & Reminders'), findsNothing);
    });

    testWidgets('Tab Switching - Navigation to Tasks tab works', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      // Select 'Tasks' tab (index 1) via selectTab helper
      final state = tester.state<DashboardScreenState>(find.byType(DashboardScreen));
      state.selectTab(1);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Verify 'Tasks & Reminders' title is now visible
      expect(find.text('Tasks & Reminders'), findsOneWidget);
    });
  });
}
