import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:tick_notes/core/theme/theme_notifier.dart';
import 'package:tick_notes/core/notifications/notification_service.dart';
import 'package:tick_notes/features/notes/note_editor_screen.dart';
import 'package:tick_notes/features/todo/todo_editor_screen.dart';
import 'Constants/routes.dart';
import 'package:tick_notes/core/splash/animated_splash_screen.dart';

void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Hold the native splash visible until AnimatedSplashScreen signals it to go away.
  // This closes the white-screen gap between native splash and Flutter first frame.
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize NotificationService asynchronously in the background so it doesn't block startup
  NotificationService.instance.init().catchError((e, stack) {
    debugPrint('Failed to initialize NotificationService: $e');
    debugPrint(stack.toString());
  });

  // NotificationService init is already above.

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeSettings = ref.watch(themeNotifierProvider);

    return MaterialApp(
      title: 'Tick Notes',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeSettings.seedColor,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeSettings.seedColor,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: themeSettings.themeMode,
      home: const AnimatedSplashScreen(),
      routes: {
        createOrUpdateNoteRoute: (context) => const NoteEditorScreen(),
        createOrUpdateTodoRoute: (context) => const TodoEditorScreen(),
      },
    );
  }
}

