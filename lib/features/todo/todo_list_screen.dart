import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'todo_view_model.dart';
import '../../Utilities/theme_utils.dart';
import '../../core/database/app_database.dart';
import '../../Constants/routes.dart';
import 'package:share_plus/share_plus.dart';

class TodoListScreen extends ConsumerStatefulWidget {
  const TodoListScreen({super.key});

  @override
  ConsumerState<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends ConsumerState<TodoListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _formatDueDate(DateTime? date) {
    if (date == null) return 'No due date';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);

    final diff = target.difference(today).inDays;
    final timeStr = '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';

    if (diff == 0) {
      return 'Today at $timeStr';
    } else if (diff == 1) {
      return 'Tomorrow at $timeStr';
    } else if (diff == -1) {
      return 'Yesterday at $timeStr';
    } else {
      return '${date.day}/${date.month}/${date.year} at $timeStr';
    }
  }

  Future<void> _shareTodos(List<Todo> todos, String categoryName) async {
    if (todos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No tasks in $categoryName to share')),
      );
      return;
    }

    final buffer = StringBuffer('TickNotes - $categoryName Tasks:\n\n');
    for (var i = 0; i < todos.length; i++) {
      final t = todos[i];
      final status = t.isCompleted ? '[x]' : '[ ]';
      final due = t.dueDate != null ? ' (Due: ${_formatDueDate(t.dueDate)})' : '';
      buffer.writeln('${i + 1}. $status ${t.title}$due');
    }

    await SharePlus.instance.share(ShareParams(text: buffer.toString().trim()));
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_outline_outlined,
              size: 72,
              color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final todosAsync = ref.watch(todoViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tasks & Reminders'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: todosAsync.when(
        data: (todos) {
          final now = DateTime.now();
          final todayStart = DateTime(now.year, now.month, now.day);
          final todayEnd = todayStart.add(const Duration(days: 1));

          final uncompleted = todos.where((t) => !t.isCompleted).toList();

          final todayTasks = uncompleted.where((t) {
            if (t.dueDate == null) return false;
            return t.dueDate!.isAfter(todayStart) && t.dueDate!.isBefore(todayEnd);
          }).toList();

          final upcomingTasks = uncompleted.where((t) {
            if (t.dueDate == null) return true; // Tasks without due date belong in upcoming/backlog
            return t.dueDate!.isAfter(todayEnd);
          }).toList();

          final completedTasks = todos.where((t) => t.isCompleted).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              _buildTodoList(todayTasks, 'Today'),
              _buildTodoList(upcomingTasks, 'Upcoming'),
              _buildTodoList(completedTasks, 'Completed'),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).pushNamed(createOrUpdateTodoRoute);
        },
        child: const Icon(Icons.add_task),
      ),
    );
  }

  Widget _buildTodoList(List<Todo> todos, String categoryName) {
    if (todos.isEmpty) {
      return _buildEmptyState('No tasks in $categoryName');
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$categoryName (${todos.length})',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              TextButton.icon(
                onPressed: () => _shareTodos(todos, categoryName),
                icon: const Icon(Icons.share, size: 16),
                label: const Text('Share List'),
              )
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: todos.length,
            itemBuilder: (context, index) {
              final todo = todos[index];
              final cardColor = getNoteColor(context, todo.colorTag);

              return Dismissible(
                key: ValueKey<int>(todo.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20.0),
                  child: Icon(
                    Icons.delete_outline,
                    color: Theme.of(context).colorScheme.onErrorContainer,
                    size: 24,
                  ),
                ),
                onDismissed: (direction) async {
                  final deletedTodo = todo;
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  await ref.read(todoViewModelProvider.notifier).deleteTodo(todo.id);

                  scaffoldMessenger.clearSnackBars();
                  scaffoldMessenger.showSnackBar(
                    SnackBar(
                      content: Text('Deleted "${todo.title}"'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () async {
                          await ref.read(todoViewModelProvider.notifier).restoreTodo(deletedTodo);
                        },
                      ),
                    ),
                  );
                },
                child: RepaintBoundary(
                  child: AnimatedTodoCard(
                    todo: todo,
                    cardColor: cardColor,
                    formatDueDate: _formatDueDate,
                    onToggle: () {
                      ref.read(todoViewModelProvider.notifier).toggleComplete(todo);
                    },
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class AnimatedTodoCard extends StatefulWidget {
  final Todo todo;
  final Color cardColor;
  final String Function(DateTime?) formatDueDate;
  final VoidCallback onToggle;

  const AnimatedTodoCard({
    super.key,
    required this.todo,
    required this.cardColor,
    required this.formatDueDate,
    required this.onToggle,
  });

  @override
  State<AnimatedTodoCard> createState() => _AnimatedTodoCardState();
}

class _AnimatedTodoCardState extends State<AnimatedTodoCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        color: widget.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: 0.3),
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.of(context).pushNamed(
              createOrUpdateTodoRoute,
              arguments: widget.todo,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    _animController.forward().then((_) {
                      _animController.reverse();
                      widget.onToggle();
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: widget.todo.isCompleted
                          ? Theme.of(context).colorScheme.primary
                          : Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.todo.isCompleted
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.outline,
                        width: 2,
                      ),
                    ),
                    child: widget.todo.isCompleted
                        ? const Icon(
                            Icons.check,
                            size: 16,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.todo.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: widget.todo.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          color: widget.todo.isCompleted
                              ? Theme.of(context).colorScheme.outline
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.formatDueDate(widget.todo.dueDate),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                      ),
                    ],
                  ),
                ),
                if (widget.todo.dueDate != null && !widget.todo.isCompleted)
                  Icon(
                    Icons.alarm,
                    size: 18,
                    color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.6),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
