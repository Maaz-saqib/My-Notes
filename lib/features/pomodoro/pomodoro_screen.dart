import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pomodoro_view_model.dart';

class PomodoroScreen extends ConsumerStatefulWidget {
  const PomodoroScreen({super.key});

  @override
  ConsumerState<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends ConsumerState<PomodoroScreen>
    with WidgetsBindingObserver {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    final isResumed = state == AppLifecycleState.resumed;
    ref.read(pomodoroViewModelProvider.notifier).handleLifecycleChange(isResumed);
  }

  String _formatDuration(Duration duration) {
    final mins = duration.inMinutes.toString().padLeft(2, '0');
    final secs = (duration.inSeconds % 60).toString().padLeft(2, '0');
    return '$mins:$secs';
  }

  void _showSettingsBottomSheet() {
    final notifier = ref.read(pomodoroViewModelProvider.notifier);
    int selectedFocus = notifier.customFocusMins;
    int selectedBreak = notifier.customBreakMins;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timer Settings',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20),
                  Text('Focus Duration: $selectedFocus mins'),
                  Slider(
                    value: selectedFocus.toDouble(),
                    min: 1,
                    max: 60,
                    divisions: 59,
                    onChanged: (val) {
                      setModalState(() {
                        selectedFocus = val.round();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('Break Duration: $selectedBreak mins'),
                  Slider(
                    value: selectedBreak.toDouble(),
                    min: 1,
                    max: 30,
                    divisions: 29,
                    onChanged: (val) {
                      setModalState(() {
                        selectedBreak = val.round();
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        ref.read(pomodoroViewModelProvider.notifier)
                            .updateCustomDurations(
                              focusMins: selectedFocus,
                              breakMins: selectedBreak,
                            );
                        Navigator.of(context).pop();
                      },
                      child: const Text('Save Settings'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(pomodoroViewModelProvider);
    final notifier = ref.read(pomodoroViewModelProvider.notifier);

    final total = timerState.durationLimit.inSeconds;
    final elapsed = timerState.elapsedDuration.inSeconds;
    final progress = total > 0 ? elapsed / total : 0.0;

    String modeLabel = '';
    String subLabel = '';
    Color themeColor = Theme.of(context).colorScheme.primary;

    if (timerState.mode == FocusMode.open) {
      modeLabel = 'Open Focus';
      themeColor = Colors.blue;
      subLabel = 'No target — stop anytime';
    } else {
      if (timerState.pomodoroPhase == PomodoroPhase.focus) {
        modeLabel = 'Focus Phase';
        themeColor = Colors.redAccent;
        subLabel = 'Session ${timerState.pomodoroSession} of 4';
      } else {
        modeLabel = 'Break Phase';
        themeColor = Colors.green;
        subLabel = 'Time to relax';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Focus Timer'),
        actions: [
          if (timerState.mode == FocusMode.pomodoro)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showSettingsBottomSheet,
            ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Segmented controls for Mode Selection
              SegmentedButton<FocusMode>(
                segments: const [
                  ButtonSegment(
                    value: FocusMode.pomodoro,
                    label: Text('Pomodoro'),
                    icon: Icon(Icons.work_outline),
                  ),
                  ButtonSegment(
                    value: FocusMode.open,
                    label: Text('Open Focus'),
                    icon: Icon(Icons.timer_outlined),
                  ),
                ],
                selected: {timerState.mode},
                onSelectionChanged: (timerState.isRunning || timerState.elapsedDuration > Duration.zero)
                    ? null
                    : (selection) {
                        notifier.setMode(selection.first);
                      },
              ),
              const SizedBox(height: 48),
              // Timer Display
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 250,
                    height: 250,
                    child: CircularProgressIndicator(
                      value: timerState.mode == FocusMode.open
                          ? 0.0 // Keep empty/clean for open count up
                          : 1.0 - progress, // Countdown visual
                      strokeWidth: 10,
                      backgroundColor: themeColor.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(themeColor),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _formatDuration(timerState.mode == FocusMode.open
                            ? timerState.elapsedDuration
                            : (timerState.durationLimit - timerState.elapsedDuration)),
                        style: Theme.of(context).textTheme.displayLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        modeLabel,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subLabel,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 48),
              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Stop Button: Smaller, on the left, visible if running or paused (if progress exists)
                  if (timerState.elapsedDuration > Duration.zero || timerState.isRunning) ...[
                    IconButton.filledTonal(
                      iconSize: 24,
                      icon: const Icon(Icons.stop),
                      onPressed: () => notifier.stopSession(),
                    ),
                    const SizedBox(width: 24),
                  ],
                  // Play/Pause Button: Large, centered
                  if (timerState.isRunning)
                    IconButton.filled(
                      iconSize: 44,
                      icon: const Icon(Icons.pause),
                      onPressed: () => notifier.pauseSession(),
                    )
                  else
                    IconButton.filled(
                      iconSize: 44,
                      icon: const Icon(Icons.play_arrow),
                      onPressed: () => notifier.startSession(),
                    ),
                  // Skip Button: Smaller, on the right, Pomodoro only
                  if (timerState.mode == FocusMode.pomodoro &&
                      (timerState.elapsedDuration > Duration.zero || timerState.isRunning)) ...[
                    const SizedBox(width: 24),
                    IconButton.filledTonal(
                      iconSize: 24,
                      icon: const Icon(Icons.skip_next),
                      onPressed: () => notifier.skipSession(),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
