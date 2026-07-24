import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:tick_notes/core/database/app_database.dart';
import 'package:tick_notes/core/notifications/notification_service.dart';
import 'package:tick_notes/features/pomodoro/pomodoro_repository.dart';
import 'package:tick_notes/features/pomodoro/pomodoro_view_model.dart';

// ── Mocks ──────────────────────────────────────────────────────────────
class MockPomodoroRepository extends Mock implements PomodoroRepository {}

class MockNotificationService extends Mock implements NotificationService {}

// ── Fallback values ─────────────────────────────────────────────────
class FakePomodoroSessionsCompanion extends Fake
    implements PomodoroSessionsCompanion {}

void main() {
  late MockPomodoroRepository mockRepo;
  late MockNotificationService mockNotifications;
  late ProviderContainer container;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(FakePomodoroSessionsCompanion());
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockRepo = MockPomodoroRepository();
    mockNotifications = MockNotificationService();

    container = ProviderContainer(
      overrides: [
        pomodoroRepositoryProvider.overrideWithValue(mockRepo),
        notificationServiceProvider.overrideWithValue(mockNotifications),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('PomodoroViewModel - Initial State', () {
    test('default state is pomodoro mode, focus phase, not running, 25 min',
        () {
      // Act
      final state = container.read(pomodoroViewModelProvider);

      // Assert
      expect(state.mode, equals(FocusMode.pomodoro));
      expect(state.pomodoroPhase, equals(PomodoroPhase.focus));
      expect(state.isRunning, isFalse);
      expect(state.durationLimit, equals(const Duration(minutes: 25)));
      expect(state.elapsedDuration, equals(Duration.zero));
      expect(state.pomodoroSession, equals(1));
    });
  });

  group('PomodoroViewModel - Start Session', () {
    test('startSession sets isRunning to true', () {
      // Arrange
      when(
        () => mockNotifications.scheduleNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledTime: any(named: 'scheduledTime'),
        ),
      ).thenAnswer((_) async {});

      // Act
      container.read(pomodoroViewModelProvider); // trigger build
      container.read(pomodoroViewModelProvider.notifier).startSession();
      final state = container.read(pomodoroViewModelProvider);

      // Assert
      expect(state.isRunning, isTrue);
      expect(state.sessionStart, isNotNull);
    });

    test('startSession schedules notification for focus end', () {
      // Arrange
      when(
        () => mockNotifications.scheduleNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledTime: any(named: 'scheduledTime'),
        ),
      ).thenAnswer((_) async {});

      // Act
      container.read(pomodoroViewModelProvider); // trigger build
      container.read(pomodoroViewModelProvider.notifier).startSession();

      // Assert
      verify(
        () => mockNotifications.scheduleNotification(
          id: 9999,
          title: 'Focus Timer Done',
          body: 'Time to take a break!',
          scheduledTime: any(named: 'scheduledTime'),
        ),
      ).called(1);
    });
  });

  group('PomodoroViewModel - Stop Session', () {
    test('stopSession sets isRunning to false', () {
      // Arrange
      when(
        () => mockNotifications.scheduleNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledTime: any(named: 'scheduledTime'),
        ),
      ).thenAnswer((_) async {});
      when(() => mockNotifications.cancelNotification(any()))
          .thenAnswer((_) async {});

      // Start the session first
      container.read(pomodoroViewModelProvider);
      container.read(pomodoroViewModelProvider.notifier).startSession();
      expect(container.read(pomodoroViewModelProvider).isRunning, isTrue);

      // Act
      container.read(pomodoroViewModelProvider.notifier).stopSession();
      final state = container.read(pomodoroViewModelProvider);

      // Assert
      expect(state.isRunning, isFalse);
      verify(() => mockNotifications.cancelNotification(9999)).called(1);
    });

    test(
        'stopSession with < 10 seconds elapsed does NOT save to repository',
        () {
      // Arrange — elapsed is Duration.zero (just started, instantly stopped)
      when(
        () => mockNotifications.scheduleNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledTime: any(named: 'scheduledTime'),
        ),
      ).thenAnswer((_) async {});
      when(() => mockNotifications.cancelNotification(any()))
          .thenAnswer((_) async {});

      // Start and immediately stop (0 elapsed seconds)
      container.read(pomodoroViewModelProvider);
      container.read(pomodoroViewModelProvider.notifier).startSession();
      container.read(pomodoroViewModelProvider.notifier).stopSession();

      // Assert — repository.add should never be called
      verifyNever(() => mockRepo.add(any()));
    });
  });

  group('PomodoroViewModel - Mode Switching', () {
    test('setMode to open resets state with zero duration limit', () {
      // Act
      container.read(pomodoroViewModelProvider);
      container.read(pomodoroViewModelProvider.notifier).setMode(FocusMode.open);
      final state = container.read(pomodoroViewModelProvider);

      // Assert
      expect(state.mode, equals(FocusMode.open));
      expect(state.durationLimit, equals(Duration.zero));
      expect(state.isRunning, isFalse);
    });

    test('setMode back to pomodoro resets with 25 min focus', () {
      // Act
      container.read(pomodoroViewModelProvider);
      final notifier = container.read(pomodoroViewModelProvider.notifier);
      notifier.setMode(FocusMode.open);
      notifier.setMode(FocusMode.pomodoro);
      final state = container.read(pomodoroViewModelProvider);

      // Assert
      expect(state.mode, equals(FocusMode.pomodoro));
      expect(state.durationLimit, equals(const Duration(minutes: 25)));
      expect(state.pomodoroPhase, equals(PomodoroPhase.focus));
    });
  });

  group('PomodoroViewModel - Pause Session', () {
    test('pauseSession sets isRunning to false and cancels notification', () {
      // Arrange
      when(
        () => mockNotifications.scheduleNotification(
          id: any(named: 'id'),
          title: any(named: 'title'),
          body: any(named: 'body'),
          scheduledTime: any(named: 'scheduledTime'),
        ),
      ).thenAnswer((_) async {});
      when(() => mockNotifications.cancelNotification(any()))
          .thenAnswer((_) async {});

      // Start, then pause
      container.read(pomodoroViewModelProvider);
      container.read(pomodoroViewModelProvider.notifier).startSession();
      container.read(pomodoroViewModelProvider.notifier).pauseSession();
      final state = container.read(pomodoroViewModelProvider);

      // Assert
      expect(state.isRunning, isFalse);
      verify(() => mockNotifications.cancelNotification(9999)).called(1);
    });
  });
}
