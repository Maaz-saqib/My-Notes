import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dashboard_view_model.dart';
import 'package:tick_notes/core/onboarding/onboarding_service.dart';
import 'package:tick_notes/features/notes/notes_list_screen.dart';
import 'package:tick_notes/features/todo/todo_list_screen.dart';
import 'package:tick_notes/features/pomodoro/pomodoro_screen.dart';
import 'package:tick_notes/features/analytics/analytics_screen.dart';
import '../../core/widgets/lazy_indexed_stack.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _currentIndex = 0;

  final GlobalKey notesTabKey = GlobalKey();
  final GlobalKey tasksTabKey = GlobalKey();
  final GlobalKey focusTabKey = GlobalKey();
  final GlobalKey addNoteKey = GlobalKey();
  final GlobalKey statsTabKey = GlobalKey();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      NotesListScreen(addNoteKey: addNoteKey),
      const TodoListScreen(),
      const PomodoroScreen(),
      const AnalyticsScreen(),
    ];

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final shouldShow = await ref.read(dashboardViewModelProvider.notifier).shouldShowOnboarding();
      if (!shouldShow) return;

      if (mounted) {
        OnboardingService.instance.showOnboarding(
          context,
          notesTabKey: notesTabKey,
          tasksTabKey: tasksTabKey,
          focusTabKey: focusTabKey,
          addNoteKey: addNoteKey,
          statsTabKey: statsTabKey,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !OnboardingService.instance.isShowing,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (OnboardingService.instance.isShowing) {
          OnboardingService.instance.skip();
        }
      },
      child: Scaffold(
        body: LazyIndexedStack(
          index: _currentIndex,
          children: _screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          destinations: [
            NavigationDestination(
              key: notesTabKey,
              icon: const Icon(Icons.note_alt_outlined),
              selectedIcon: const Icon(Icons.note_alt),
              label: 'Notes',
            ),
            NavigationDestination(
              key: tasksTabKey,
              icon: const Icon(Icons.check_circle_outline),
              selectedIcon: const Icon(Icons.check_circle),
              label: 'Tasks',
            ),
            NavigationDestination(
              key: focusTabKey,
              icon: const Icon(Icons.timer_outlined),
              selectedIcon: const Icon(Icons.timer),
              label: 'Focus',
            ),
            NavigationDestination(
              key: statsTabKey,
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: const Icon(Icons.bar_chart),
              label: 'Stats',
            ),
          ],
        ),
      ),
    );
  }
}

