import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tick_notes/core/database/app_database.dart';
import 'package:tick_notes/features/todo/todo_list_screen.dart';

void main() {
  group('AnimatedTodoCard Widget Tests', () {
    testWidgets('Uncompleted State Rendering', (WidgetTester tester) async {
      final uncompletedTodo = Todo(
        id: 1,
        title: 'Learn Flutter Widget Testing',
        dueDate: null,
        isCompleted: false,
        colorTag: 0,
        hasAlarm: false,
        alarmSound: 'default',
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedTodoCard(
              todo: uncompletedTodo,
              cardColor: Colors.white,
              formatDueDate: (date) => 'No due date',
              onToggle: () {},
            ),
          ),
        ),
      );

      // Verify todo title text renders
      final titleFinder = find.text('Learn Flutter Widget Testing');
      expect(titleFinder, findsOneWidget);

      // Verify the text does NOT have a strikethrough decoration
      final textWidget = tester.widget<Text>(titleFinder);
      expect(textWidget.style?.decoration, TextDecoration.none);

      // Verify the check icon is not visible
      expect(find.byIcon(Icons.check), findsNothing);
    });

    testWidgets('Completed State Rendering', (WidgetTester tester) async {
      final completedTodo = Todo(
        id: 2,
        title: 'Write Widget Tests',
        dueDate: null,
        isCompleted: true,
        colorTag: 0,
        hasAlarm: false,
        alarmSound: 'default',
        updatedAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedTodoCard(
              todo: completedTodo,
              cardColor: Colors.white,
              formatDueDate: (date) => 'No due date',
              onToggle: () {},
            ),
          ),
        ),
      );

      // Verify todo title text renders
      final titleFinder = find.text('Write Widget Tests');
      expect(titleFinder, findsOneWidget);

      // Verify the text HAS a strikethrough decoration
      final textWidget = tester.widget<Text>(titleFinder);
      expect(textWidget.style?.decoration, TextDecoration.lineThrough);

      // Verify the checkbox icon shows a checkmark
      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('Toggle Callback', (WidgetTester tester) async {
      final todo = Todo(
        id: 3,
        title: 'Tap test',
        dueDate: null,
        isCompleted: false,
        colorTag: 2,
        hasAlarm: false,
        alarmSound: 'default',
        updatedAt: DateTime.now(),
      );

      var toggled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedTodoCard(
              todo: todo,
              cardColor: Colors.white,
              formatDueDate: (date) => 'No due date',
              onToggle: () {
                toggled = true;
              },
            ),
          ),
        ),
      );

      // Tap the circular checkbox widget (the AnimatedContainer inside the GestureDetector)
      final checkboxFinder = find.byType(AnimatedContainer);
      expect(checkboxFinder, findsOneWidget);

      await tester.tap(checkboxFinder);
      
      // Let the animation drive and trigger .then callback
      await tester.pumpAndSettle();

      // Verify the callback was triggered
      expect(toggled, isTrue);
    });
  });
}
