import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import 'todo_repository.dart';
import '../../core/database/app_database.dart';
import '../../core/notifications/notification_service.dart';

part 'todo_view_model.g.dart';

@riverpod
class TodoViewModel extends _$TodoViewModel {
  @override
  Stream<List<Todo>> build() {
    return ref.watch(todoRepositoryProvider).watchAll();
  }

  Future<int> addTodo({
    required String title,
    required DateTime? dueDate,
    required int colorTag,
    required bool hasReminder,
    required bool hasAlarm,
    required String alarmSound,
  }) async {
    final now = DateTime.now();
    final companion = TodosCompanion.insert(
      title: title,
      dueDate: Value(dueDate),
      colorTag: Value(colorTag),
      isCompleted: const Value(false),
      hasAlarm: Value(hasAlarm),
      alarmSound: Value(alarmSound),
      updatedAt: now,
    );

    final id = await ref.read(todoRepositoryProvider).add(companion);

    if (hasReminder && dueDate != null) {
      await _scheduleTodoNotification(id, title, dueDate, hasAlarm, alarmSound);
    }

    return id;
  }

  Future<void> updateTodo({
    required int id,
    required String title,
    required DateTime? dueDate,
    required int colorTag,
    required bool isCompleted,
    required bool hasReminder,
    required bool hasAlarm,
    required String alarmSound,
  }) async {
    final companion = TodosCompanion(
      title: Value(title),
      dueDate: Value(dueDate),
      colorTag: Value(colorTag),
      isCompleted: Value(isCompleted),
      hasAlarm: Value(hasAlarm),
      alarmSound: Value(alarmSound),
      updatedAt: Value(DateTime.now()),
    );

    await ref.read(todoRepositoryProvider).updateTodo(id, companion);

    // Cancel old reminder
    await ref.read(notificationServiceProvider).cancelNotification(id);

    // Schedule new one if not completed, reminder is requested, and due date is in the future
    if (!isCompleted && hasReminder && dueDate != null && dueDate.isAfter(DateTime.now())) {
      await _scheduleTodoNotification(id, title, dueDate, hasAlarm, alarmSound);
    }
  }

  Future<void> toggleComplete(Todo todo) async {
    final isCompleted = !todo.isCompleted;
    final companion = TodosCompanion(
      isCompleted: Value(isCompleted),
      updatedAt: Value(DateTime.now()),
    );

    await ref.read(todoRepositoryProvider).updateTodo(todo.id, companion);

    if (isCompleted) {
      await ref.read(notificationServiceProvider).cancelNotification(todo.id);
    } else {
      // If uncompleted and original note had reminder setup (meaning dueDate is not null), we should schedule if due date is still valid.
      // For simplicity, we check if it has a due date in the future and schedule it.
      if (todo.dueDate != null && todo.dueDate!.isAfter(DateTime.now())) {
        await _scheduleTodoNotification(todo.id, todo.title, todo.dueDate!, todo.hasAlarm, todo.alarmSound);
      }
    }
  }

  Future<void> deleteTodo(int id) async {
    await ref.read(todoRepositoryProvider).delete(id);
    await ref.read(notificationServiceProvider).cancelNotification(id);
  }

  Future<int> restoreTodo(Todo todo) async {
    final companion = TodosCompanion.insert(
      title: todo.title,
      dueDate: Value(todo.dueDate),
      colorTag: Value(todo.colorTag),
      isCompleted: Value(todo.isCompleted),
      hasAlarm: Value(todo.hasAlarm),
      alarmSound: Value(todo.alarmSound),
      updatedAt: todo.updatedAt,
    );

    final id = await ref.read(todoRepositoryProvider).add(companion);

    if (!todo.isCompleted && todo.dueDate != null && todo.dueDate!.isAfter(DateTime.now())) {
      await _scheduleTodoNotification(id, todo.title, todo.dueDate!, todo.hasAlarm, todo.alarmSound);
    }

    return id;
  }

  Future<void> _scheduleTodoNotification(int id, String title, DateTime scheduledTime, bool hasAlarm, String alarmSound) async {
    // Request permission just in case
    await ref.read(notificationServiceProvider).requestPermissions();
    await ref.read(notificationServiceProvider).scheduleNotification(
      id: id,
      title: 'Task Reminder',
      body: title.isNotEmpty ? title : 'Untitled Task is due now!',
      scheduledTime: scheduledTime,
      playSound: hasAlarm && alarmSound != 'silent',
    );
  }
}
