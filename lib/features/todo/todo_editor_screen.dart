import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todo_view_model.dart';
import '../../core/database/app_database.dart';
import '../../Utilities/Generics/get_arguments.dart';

class TodoEditorScreen extends ConsumerStatefulWidget {
  const TodoEditorScreen({super.key});

  @override
  ConsumerState<TodoEditorScreen> createState() => _TodoEditorScreenState();
}

class _TodoEditorScreenState extends ConsumerState<TodoEditorScreen> {
  Todo? _todo;
  late final TextEditingController _titleController;
  DateTime? _dueDate;
  TimeOfDay? _dueTime;
  bool _hasReminder = false;
  bool _hasAlarm = false;
  String _alarmSound = 'default';
  bool _isInitialized = false;

  @override
  void initState() {
    _titleController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _initializeData() {
    if (_isInitialized) return;

    final argumentTodo = context.getArgument<Todo>();
    if (argumentTodo != null) {
      _todo = argumentTodo;
      _titleController.text = argumentTodo.title;
      if (argumentTodo.dueDate != null) {
        _dueDate = argumentTodo.dueDate;
        _dueTime = TimeOfDay.fromDateTime(argumentTodo.dueDate!);
        _hasReminder = true; // For editing convenience, assume true if dueDate exists
        _hasAlarm = argumentTodo.hasAlarm;
        _alarmSound = argumentTodo.alarmSound;
      }
    }
    _isInitialized = true;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked != null && picked != _dueDate) {
      setState(() {
        _dueDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _dueTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _dueTime) {
      setState(() {
        _dueTime = picked;
      });
    }
  }

  Future<void> _saveTodo() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title')),
      );
      return;
    }

    DateTime? finalDueDate;
    if (_dueDate != null) {
      final time = _dueTime ?? const TimeOfDay(hour: 12, minute: 0);
      finalDueDate = DateTime(
        _dueDate!.year,
        _dueDate!.month,
        _dueDate!.day,
        time.hour,
        time.minute,
      );
    }

    if (_todo != null) {
      // Update (passing 0 for colorTag)
      await ref.read(todoViewModelProvider.notifier).updateTodo(
            id: _todo!.id,
            title: title,
            dueDate: finalDueDate,
            colorTag: 0,
            isCompleted: _todo!.isCompleted,
            hasReminder: _hasReminder,
            hasAlarm: _hasAlarm,
            alarmSound: _alarmSound,
          );
    } else {
      // Add (passing 0 for colorTag)
      await ref.read(todoViewModelProvider.notifier).addTodo(
            title: title,
            dueDate: finalDueDate,
            colorTag: 0,
            hasReminder: _hasReminder,
            hasAlarm: _hasAlarm,
            alarmSound: _alarmSound,
          );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    _initializeData();

    return Scaffold(
      appBar: AppBar(
        title: Text(_todo != null ? 'Edit Task' : 'New Task'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveTodo,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'What needs to be done?',
                border: InputBorder.none,
                hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              maxLines: null,
            ),
            const Divider(height: 32),
            Text(
              'Schedule',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Card(
              elevation: 0,
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.calendar_today),
                      title: Text(_dueDate == null
                          ? 'Set Due Date'
                          : '${_dueDate!.day}/${_dueDate!.month}/${_dueDate!.year}'),
                      trailing: _dueDate != null
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setState(() {
                                  _dueDate = null;
                                  _dueTime = null;
                                  _hasReminder = false;
                                });
                              },
                            )
                          : null,
                      onTap: () => _selectDate(context),
                    ),
                    if (_dueDate != null) ...[
                      const Divider(height: 1),
                      ListTile(
                        leading: const Icon(Icons.access_time),
                        title: Text(_dueTime == null ? 'Set Time' : _dueTime!.format(context)),
                        onTap: () => _selectTime(context),
                      ),
                      const Divider(height: 1),
                      SwitchListTile(
                        secondary: const Icon(Icons.notifications_active_outlined),
                        title: const Text('Set Reminder Notification'),
                        value: _hasReminder,
                        onChanged: (val) {
                          setState(() {
                            _hasReminder = val;
                          });
                        },
                      ),
                      if (_hasReminder) ...[
                        const Divider(height: 1),
                        SwitchListTile(
                          secondary: const Icon(Icons.alarm),
                          title: const Text('Play Alarm Sound'),
                          value: _hasAlarm,
                          onChanged: (val) {
                            setState(() {
                              _hasAlarm = val;
                            });
                          },
                        ),
                        if (_hasAlarm) ...[
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.music_note),
                            title: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _alarmSound,
                                isExpanded: true,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'default',
                                    child: Text('Default Notification Sound'),
                                  ),
                                ],
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() {
                                      _alarmSound = val;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
