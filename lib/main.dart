import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:tick_notes/core/theme/theme_notifier.dart';
import 'package:tick_notes/core/notifications/notification_service.dart';
import 'package:tick_notes/features/notes/note_editor_screen.dart';
import 'package:tick_notes/features/todo/todo_editor_screen.dart';
import 'Constants/routes.dart';
import 'package:tick_notes/core/splash/home_page.dart';

void main() {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Catch synchronous Flutter framework errors
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Global Flutter Error: ${details.exceptionAsString()}');
  };

  // Catch asynchronous errors in the root isolate
  WidgetsBinding.instance.platformDispatcher.onError = (error, stack) {
    debugPrint('Global Async Error: $error');
    debugPrint(stack.toString());
    return true; // Handled
  };

  // Custom UI fallback error widget instead of red/grey screen
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 48),
              const SizedBox(height: 12),
              const Text(
                'Something went wrong displaying this section.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  };

  // Hold native splash visible until Dashboard signals it to go away
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize NotificationService asynchronously in the background
  NotificationService.instance.init().catchError((e, stack) {
    debugPrint('Failed to initialize NotificationService: $e');
    debugPrint(stack.toString());
  });

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
      home: const HomePage(),
      routes: {
        createOrUpdateNoteRoute: (context) => const NoteEditorScreen(),
        createOrUpdateTodoRoute: (context) => const TodoEditorScreen(),
      },
    );
  }
}

