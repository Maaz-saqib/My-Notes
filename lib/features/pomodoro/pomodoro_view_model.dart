import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pomodoro_repository.dart';
import '../../core/database/app_database.dart';
import '../../core/notifications/notification_service.dart';

part 'pomodoro_view_model.g.dart';
enum FocusMode { pomodoro, open }

enum PomodoroPhase { focus, breakPhase }

class PomodoroState {
  final FocusMode mode;
  final PomodoroPhase pomodoroPhase;
  final int pomodoroSession; // ranges from 1 to 4
  final bool isRunning;
  final Duration durationLimit;
  final Duration elapsedDuration;
  final DateTime? sessionStart;
  final DateTime? lastTickTime;

  const PomodoroState({
    required this.mode,
    required this.pomodoroPhase,
    required this.pomodoroSession,
    required this.isRunning,
    required this.durationLimit,
    required this.elapsedDuration,
    this.sessionStart,
    this.lastTickTime,
  });

  PomodoroState copyWith({
    FocusMode? mode,
    PomodoroPhase? pomodoroPhase,
    int? pomodoroSession,
    bool? isRunning,
    Duration? durationLimit,
    Duration? elapsedDuration,
    DateTime? sessionStart,
    DateTime? lastTickTime,
  }) {
    return PomodoroState(
      mode: mode ?? this.mode,
      pomodoroPhase: pomodoroPhase ?? this.pomodoroPhase,
      pomodoroSession: pomodoroSession ?? this.pomodoroSession,
      isRunning: isRunning ?? this.isRunning,
      durationLimit: durationLimit ?? this.durationLimit,
      elapsedDuration: elapsedDuration ?? this.elapsedDuration,
      sessionStart: sessionStart ?? this.sessionStart,
      lastTickTime: lastTickTime ?? this.lastTickTime,
    );
  }
}

@Riverpod(keepAlive: true)
class PomodoroViewModel extends _$PomodoroViewModel {
  Timer? _timer;
  Duration _customFocusDuration = const Duration(minutes: 25);
  Duration _customBreakDuration = const Duration(minutes: 5);

  @override
  PomodoroState build() {
    final observer = _LifecycleObserver(this);
    WidgetsBinding.instance.addObserver(observer);
    
    ref.onDispose(() {
      WidgetsBinding.instance.removeObserver(observer);
      _timer?.cancel();
    });
    
    _loadState();

    return PomodoroState(
      mode: FocusMode.pomodoro,
      pomodoroPhase: PomodoroPhase.focus,
      pomodoroSession: 1,
      isRunning: false,
      durationLimit: _customFocusDuration,
      elapsedDuration: Duration.zero,
    );
  }

  void updateCustomDurations({required int focusMins, required int breakMins}) {
    _customFocusDuration = Duration(minutes: focusMins);
    _customBreakDuration = Duration(minutes: breakMins);
    if (!state.isRunning && state.mode == FocusMode.pomodoro) {
      if (state.pomodoroPhase == PomodoroPhase.focus) {
        state = state.copyWith(durationLimit: _customFocusDuration);
      } else if (state.pomodoroPhase == PomodoroPhase.breakPhase) {
        state = state.copyWith(durationLimit: _customBreakDuration);
      }
    }
  }

  int get customFocusMins => _customFocusDuration.inMinutes;
  int get customBreakMins => _customBreakDuration.inMinutes;

  void setMode(FocusMode mode) {
    if (state.mode == mode) return;

    Duration limit = Duration.zero;
    if (mode == FocusMode.pomodoro) {
      limit = state.pomodoroPhase == PomodoroPhase.focus
          ? _customFocusDuration
          : _customBreakDuration;
    }
    
    state = state.copyWith(
      mode: mode,
      durationLimit: limit,
    );
    _saveState();
  }

  Future<void> startSession() async {
    if (state.isRunning) return;

    final now = DateTime.now();

    // The original timer relies on internal state and background delta time.
    
    state = state.copyWith(
      isRunning: true,
      sessionStart: state.sessionStart ?? now,
      lastTickTime: now,
    );

    // Schedule notification for background if we are in Pomodoro mode
    if (state.mode == FocusMode.pomodoro) {
      final remaining = state.durationLimit - state.elapsedDuration;
      final scheduledTime = now.add(remaining);
      ref.read(notificationServiceProvider).scheduleNotification(
        id: 9999, // Static ID for Pomodoro reminders
        title: state.pomodoroPhase == PomodoroPhase.focus
            ? 'Focus Timer Done'
            : 'Break Timer Done',
        body: state.pomodoroPhase == PomodoroPhase.focus
            ? 'Time to take a break!'
            : 'Break is over. Ready to focus?',
        scheduledTime: scheduledTime,
      );
    }

    _startTimer();
    _saveState();
  }

  void pauseSession() {
    if (!state.isRunning) return;
    _timer?.cancel();
    ref.read(notificationServiceProvider).cancelNotification(9999);
    state = state.copyWith(isRunning: false);
    _saveState();
  }

  void stopSession({bool forceSave = true}) {
    _timer?.cancel();
    ref.read(notificationServiceProvider).cancelNotification(9999);

    final start = state.sessionStart;
    final now = DateTime.now();

    if (forceSave && start != null) {
      final elapsedMins = state.elapsedDuration.inMinutes;
      final elapsedSecs = state.elapsedDuration.inSeconds;

      // Only save if elapsed session is meaningful (>= 10 seconds)
      if (elapsedSecs >= 10) {
        final durationMinutes = elapsedMins > 0 ? elapsedMins : 1;

        if (state.mode == FocusMode.open) {
          // Open Focus Mode: Save time with "open" mode
          ref
              .read(pomodoroRepositoryProvider)
              .add(
                PomodoroSessionsCompanion.insert(
                  startTime: start,
                  endTime: now,
                  durationMinutes: durationMinutes,
                  mode: 'open',
                ),
              );
        } else if (state.mode == FocusMode.pomodoro &&
            state.pomodoroPhase == PomodoroPhase.focus) {
          // Pomodoro Focus Phase: Save time with "pomodoro" mode
          ref
              .read(pomodoroRepositoryProvider)
              .add(
                PomodoroSessionsCompanion.insert(
                  startTime: start,
                  endTime: now,
                  durationMinutes: durationMinutes,
                  mode: 'pomodoro',
                ),
              );
        }
        // If it's a break phase, we skip database writing entirely
      }
    }

    Duration limit = Duration.zero;
    if (state.mode == FocusMode.pomodoro) {
      limit = state.pomodoroPhase == PomodoroPhase.focus
          ? _customFocusDuration
          : _customBreakDuration;
    }

    state = PomodoroState(
      mode: state.mode,
      pomodoroPhase: state.pomodoroPhase,
      pomodoroSession: state.pomodoroSession,
      isRunning: false,
      durationLimit: limit,
      elapsedDuration: Duration.zero,
      sessionStart: null,
      lastTickTime: null,
    );
    _saveState();
  }

  void skipSession() {
    stopSession(forceSave: false);
    // Cycle phases
    if (state.pomodoroPhase == PomodoroPhase.focus) {
      state = PomodoroState(
        mode: FocusMode.pomodoro,
        pomodoroPhase: PomodoroPhase.breakPhase,
        pomodoroSession: state.pomodoroSession,
        isRunning: false,
        durationLimit: _customBreakDuration,
        elapsedDuration: Duration.zero,
      );
    } else {
      final nextSession = state.pomodoroSession >= 4
          ? 1
          : state.pomodoroSession + 1;
      state = PomodoroState(
        mode: FocusMode.pomodoro,
        pomodoroPhase: PomodoroPhase.focus,
        pomodoroSession: nextSession,
        isRunning: false,
        durationLimit: _customFocusDuration,
        elapsedDuration: Duration.zero,
      );
    }
    _saveState();
  }

  void handleLifecycleChange(AppLifecycleState appState) {
    if (!state.isRunning) return;

    if (appState == AppLifecycleState.paused || 
        appState == AppLifecycleState.inactive || 
        appState == AppLifecycleState.hidden) {
      // Just save the state aggressively when minimizing, but DO NOT cancel the periodic timer!
      // The timer will gracefully continue running in the background thread (or pause and resume perfectly using delta math).
      _saveState();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      
      // Calculate true delta since last tick to handle OS suspension/minimization
      final start = state.lastTickTime ?? now.subtract(const Duration(seconds: 1));
      final delta = now.difference(start);
      final newElapsed = state.elapsedDuration + delta;

      if (state.mode == FocusMode.pomodoro &&
          newElapsed >= state.durationLimit) {
        state = state.copyWith(
          elapsedDuration: state.durationLimit,
          lastTickTime: now,
        );
        _sessionCompleted();
      } else {
        state = state.copyWith(elapsedDuration: newElapsed, lastTickTime: now);
        
        // Save state every 5 seconds so if the OS forcefully kills the app, 
        // we don't lose more than 5 seconds of progress when recovering the time delta!
        if (newElapsed.inSeconds % 5 == 0) {
          _saveState();
        }
      }
    });
  }

  void _sessionCompleted() {
    _saveState();
    final start =
        state.sessionStart ?? DateTime.now().subtract(state.durationLimit);
    final now = DateTime.now();

    // Only save if completed session was Focus, not Break
    if (state.pomodoroPhase == PomodoroPhase.focus) {
      ref
          .read(pomodoroRepositoryProvider)
          .add(
            PomodoroSessionsCompanion.insert(
              startTime: start,
              endTime: now,
              durationMinutes: state.durationLimit.inMinutes,
              mode: 'pomodoro',
            ),
          );
    }

    // Switch next phase
    if (state.pomodoroPhase == PomodoroPhase.focus) {
      state = PomodoroState(
        mode: FocusMode.pomodoro,
        pomodoroPhase: PomodoroPhase.breakPhase,
        pomodoroSession: state.pomodoroSession,
        isRunning: false,
        durationLimit: _customBreakDuration,
        elapsedDuration: Duration.zero,
      );
    } else {
      final nextSession = state.pomodoroSession >= 4
          ? 1
          : state.pomodoroSession + 1;
      state = PomodoroState(
        mode: FocusMode.pomodoro,
        pomodoroPhase: PomodoroPhase.focus,
        pomodoroSession: nextSession,
        isRunning: false,
        durationLimit: _customFocusDuration,
        elapsedDuration: Duration.zero,
      );
    }
    _saveState();
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final isRunning = prefs.getBool('pomodoro_isRunning') ?? false;
    final modeStr = prefs.getString('pomodoro_mode') ?? 'pomodoro';
    final phaseStr = prefs.getString('pomodoro_phase') ?? 'focus';
    final session = prefs.getInt('pomodoro_session') ?? 1;
    final elapsedSecs = prefs.getInt('pomodoro_elapsed') ?? 0;
    final sessionStartStr = prefs.getString('pomodoro_sessionStart');
    final lastTickTimeStr = prefs.getString('pomodoro_lastTickTime');
    
    final mode = FocusMode.values.firstWhere((e) => e.name == modeStr, orElse: () => FocusMode.pomodoro);
    final phase = PomodoroPhase.values.firstWhere((e) => e.name == phaseStr, orElse: () => PomodoroPhase.focus);
    
    Duration limit = Duration.zero;
    if (mode == FocusMode.pomodoro) {
      limit = phase == PomodoroPhase.focus ? _customFocusDuration : _customBreakDuration;
    }
    
    DateTime? sessionStart = sessionStartStr != null ? DateTime.tryParse(sessionStartStr) : null;
    DateTime? lastTickTime = lastTickTimeStr != null ? DateTime.tryParse(lastTickTimeStr) : null;
    
    Duration elapsed = Duration(seconds: elapsedSecs);
    
    if (isRunning && lastTickTime != null) {
      final now = DateTime.now();
      final delta = now.difference(lastTickTime);
      elapsed += delta;
      lastTickTime = now;
      
      if (mode == FocusMode.pomodoro && elapsed >= limit) {
        elapsed = limit;
      }
    }
    
    state = PomodoroState(
      mode: mode,
      pomodoroPhase: phase,
      pomodoroSession: session,
      isRunning: isRunning,
      durationLimit: limit,
      elapsedDuration: elapsed,
      sessionStart: sessionStart,
      lastTickTime: lastTickTime,
    );
    
    if (isRunning) {
      if (mode == FocusMode.pomodoro && elapsed >= limit) {
        _sessionCompleted();
      } else {
        _startTimer();
      }
    }
  }

  Future<void> _saveState() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('pomodoro_isRunning', state.isRunning);
    prefs.setString('pomodoro_mode', state.mode.name);
    prefs.setString('pomodoro_phase', state.pomodoroPhase.name);
    prefs.setInt('pomodoro_session', state.pomodoroSession);
    prefs.setInt('pomodoro_elapsed', state.elapsedDuration.inSeconds);
    prefs.setInt('pomodoro_duration_limit', state.durationLimit.inMinutes);
    if (state.sessionStart != null) {
      prefs.setString('pomodoro_sessionStart', state.sessionStart!.toIso8601String());
    } else {
      prefs.remove('pomodoro_sessionStart');
    }
    if (state.lastTickTime != null) {
      prefs.setString('pomodoro_lastTickTime', state.lastTickTime!.toIso8601String());
    } else {
      prefs.remove('pomodoro_lastTickTime');
    }
  }
}

class _LifecycleObserver extends WidgetsBindingObserver {
  final PomodoroViewModel notifier;
  _LifecycleObserver(this.notifier);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    notifier.handleLifecycleChange(state);
  }
}

