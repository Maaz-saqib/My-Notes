import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tick_notes/core/theme/theme_notifier.dart';
import 'notes_view_model.dart';
import '../../Utilities/theme_utils.dart';
import '../../Constants/routes.dart';
import '../../core/database/app_database.dart';
import 'checklist_item.dart';

class NotesListScreen extends ConsumerStatefulWidget {
  final GlobalKey? addNoteKey;
  const NotesListScreen({super.key, this.addNoteKey});

  @override
  ConsumerState<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends ConsumerState<NotesListScreen> {
  late final TextEditingController _searchController;
  String _searchQuery = '';

  @override
  void initState() {
    _searchController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    if (difference.inDays == 0) {
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }

  String _getNotePreview(Note note) {
    if (note.isList) {
      final items = ChecklistItem.fromJsonList(note.body);
      if (items.isEmpty) return 'No items';
      return items.map((e) => '${e.isChecked ? '[x]' : '[ ]'} ${e.text}').join('\n');
    }
    return note.body.isNotEmpty ? note.body : 'No content';
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesViewModelProvider);
    final themeSettings = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          // Theme mode toggle button
          IconButton(
            icon: Icon(
              themeSettings.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              final newMode = themeSettings.themeMode == ThemeMode.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              ref.read(themeNotifierProvider.notifier).setThemeMode(newMode);
            },
            tooltip: 'Toggle Theme',
          ),
          // Seed color changer popup menu
          PopupMenuButton<Color>(
            icon: const Icon(Icons.palette),
            onSelected: (color) {
              ref.read(themeNotifierProvider.notifier).setSeedColor(color);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: Colors.blue,
                child: Text('Blue (Default)'),
              ),
              const PopupMenuItem(value: Colors.deepPurple, child: Text('Purple')),
              const PopupMenuItem(value: Colors.teal, child: Text('Teal')),
              const PopupMenuItem(value: Colors.orange, child: Text('Orange')),
              const PopupMenuItem(value: Colors.red, child: Text('Red')),
            ],
            tooltip: 'Change Seed Color',
          ),
          IconButton(
            key: widget.addNoteKey,
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.text_fields),
                          title: const Text('Text Note'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).pushNamed(
                              createOrUpdateNoteRoute,
                              arguments: Note(id: -1, title: '', body: '', colorTag: 0, isList: false, updatedAt: DateTime.now()),
                            );
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.checklist),
                          title: const Text('Checklist'),
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).pushNamed(
                              createOrUpdateNoteRoute,
                              arguments: Note(id: -1, title: '', body: '', colorTag: 0, isList: true, updatedAt: DateTime.now()),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }
              );
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase().trim();
                });
              },
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              ),
            ),
          ),
          // Notes grid / list state
          Expanded(
            child: notesAsync.when(
              data: (notes) {
                final filteredNotes = notes.where((note) {
                  return note.title.toLowerCase().contains(_searchQuery) ||
                      note.body.toLowerCase().contains(_searchQuery);
                }).toList();

                if (notes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                                ).colorScheme.primaryContainer.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.note_alt_outlined,
                              size: 72,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'No notes yet',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the "+" icon in the top right to create your first note.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (filteredNotes.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No results found',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'No notes match "$_searchQuery". Try another search term.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
                                  color: Theme.of(context).colorScheme.outline,
                                ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 220,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: filteredNotes.length,
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    final cardColor = getNoteColor(context, note.colorTag);

                    return Dismissible(
                      key: ValueKey<int>(note.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        child: Icon(
                          Icons.delete_outline,
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          size: 28,
                        ),
                      ),
                      onDismissed: (direction) async {
                        final deletedNote = note;
                        await ref
                            .read(notesViewModelProvider.notifier)
                            .deleteNote(note.id);

                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).clearSnackBars();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Deleted "${note.title.isNotEmpty ? note.title : 'Untitled'}"',
                            ),
                            action: SnackBarAction(
                              label: 'Undo',
                              onPressed: () async {
                                await ref
                                    .read(notesViewModelProvider.notifier)
                                    .restoreNote(deletedNote);
                              },
                            ),
                            duration: const Duration(seconds: 4),
                          ),
                        );
                      },
                      child: Card(
                        color: cardColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.outlineVariant.withValues(alpha: 0.4),
                          ),
                        ),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(16),
                          onTap: () {
                            Navigator.of(context).pushNamed(
                              createOrUpdateNoteRoute,
                              arguments: note,
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  note.title.isNotEmpty
                                      ? note.title
                                      : 'Untitled',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                Expanded(
                                  child: Text(
                                    _getNotePreview(note),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                    maxLines: 4,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _formatDateTime(note.updatedAt),
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.outline,
                                        fontSize: 10,
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
