import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'notes_view_model.dart';
import '../../core/database/app_database.dart';
import '../../Utilities/Generics/get_arguments.dart';
import '../../Utilities/Dialog/cannot_share_empty_note_dialog.dart';
import '../../Utilities/theme_utils.dart';
import 'checklist_item.dart';

class NoteEditorScreen extends ConsumerStatefulWidget {
  const NoteEditorScreen({super.key});

  @override
  ConsumerState<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends ConsumerState<NoteEditorScreen> {
  Note? _note;
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  
  bool _isList = false;
  List<ChecklistItem> _checklistItems = [];
  bool _showCompleted = false;

  bool _isInitialized = false;
  NotesViewModel? _viewModel;

  @override
  void initState() {
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    super.initState();
  }

  @override
  void deactivate() {
    _viewModel = ref.read(notesViewModelProvider.notifier);
    _removeListeners();
    _saveOrDeleteNote();
    super.deactivate();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  void _saveOrDeleteNote() {
    try {
      final note = _note;
      final vm = _viewModel;
      if (note == null || vm == null) return;

      final title = _titleController.text.trim();
      final body = _isList ? ChecklistItem.toJsonList(_checklistItems) : _bodyController.text.trim();

      if (title.isEmpty && ((!_isList && body.isEmpty) || (_isList && _checklistItems.isEmpty))) {
        vm.deleteNote(note.id);
      } else {
        vm.updateNoteContent(
          note.id,
          title,
          body,
          note.colorTag,
          isList: _isList,
        );
      }
    } catch (e) {
      debugPrint('NoteEditorScreen._saveOrDeleteNote error: $e');
    }
  }

  void _setupListeners() {
    _titleController.addListener(_onTextChanged);
    _bodyController.addListener(_onTextChanged);
  }

  void _removeListeners() {
    _titleController.removeListener(_onTextChanged);
    _bodyController.removeListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (!mounted) return;
    final note = _note;
    if (note == null) return;
    ref.read(notesViewModelProvider.notifier).updateNoteContent(
          note.id,
          _titleController.text,
          _isList ? ChecklistItem.toJsonList(_checklistItems) : _bodyController.text,
          note.colorTag,
          isList: _isList,
        );
  }

  void _onChecklistToggled() {
    _onTextChanged();
    setState(() {}); // trigger rebuild for UI
  }

  void _onChecklistTextChangedOnly() {
    _onTextChanged(); // updates view model (and DB) without triggering rebuild
  }

  Future<Note> _createOrGetExistingNote() async {
    if (_isInitialized) {
      return _note!;
    }

    final widgetNote = context.getArgument<Note>();
    final notesViewModel = ref.read(notesViewModelProvider.notifier);

    if (widgetNote != null) {
      _isList = widgetNote.isList;
      if (widgetNote.id == -1) {
        // It's a new note, but we passed it to know if it's a list
        final newId = await notesViewModel.addNote('', '', 0, isList: _isList);
        if (!mounted) {
          await notesViewModel.deleteNote(newId);
          throw Exception('Widget disposed during note creation');
        }
        final newNote = await notesViewModel.getNoteById(newId);
        _note = newNote;
      } else {
        _note = widgetNote;
        _titleController.text = widgetNote.title;
        if (_isList) {
          _checklistItems = ChecklistItem.fromJsonList(widgetNote.body);
        } else {
          _bodyController.text = widgetNote.body;
        }
      }
    } else {
      // Creating a new note locally (default text)
      final newId = await notesViewModel.addNote('', '', 0);
      if (!mounted) {
        await notesViewModel.deleteNote(newId);
        throw Exception('Widget disposed during note creation');
      }
      final newNote = await notesViewModel.getNoteById(newId);
      _note = newNote;
    }

    _isInitialized = true;
    _setupListeners();
    return _note!;
  }

  Widget _buildChecklist() {
    final unchecked = _checklistItems.asMap().entries.where((e) => !e.value.isChecked).toList();
    final checked = _checklistItems.asMap().entries.where((e) => e.value.isChecked).toList();

    return ListView(
      children: [
        ...unchecked.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return _buildChecklistItem(index, item);
        }),
        ListTile(
          leading: const Icon(Icons.add),
          title: const Text('List item'),
          onTap: () {
            _checklistItems.add(ChecklistItem(text: ''));
            _onChecklistToggled();
          },
        ),
        if (checked.isNotEmpty) ...[
          const Divider(),
          ExpansionTile(
            title: Text('${checked.length} Checked items'),
            initiallyExpanded: _showCompleted,
            onExpansionChanged: (val) {
              setState(() {
                _showCompleted = val;
              });
            },
            children: checked.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return _buildChecklistItem(index, item);
            }).toList(),
          ),
        ]
      ],
    );
  }

  Widget _buildChecklistItem(int index, ChecklistItem item) {
    return ListTile(
      leading: Checkbox(
        value: item.isChecked,
        onChanged: (val) {
          _checklistItems[index] = item.copyWith(isChecked: val);
          _onChecklistToggled();
        },
      ),
      title: TextFormField(
        initialValue: item.text,
        decoration: const InputDecoration(
          border: InputBorder.none,
          isDense: true,
        ),
        style: TextStyle(
          decoration: item.isChecked ? TextDecoration.lineThrough : null,
          color: item.isChecked ? Theme.of(context).colorScheme.outline : null,
        ),
        onChanged: (val) {
          _checklistItems[index] = item.copyWith(text: val);
          _onChecklistTextChangedOnly();
        },
      ),
      trailing: IconButton(
        icon: const Icon(Icons.close, size: 18),
        onPressed: () {
          _checklistItems.removeAt(index);
          _onChecklistToggled();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBgColor = _note != null
        ? getNoteColor(context, _note!.colorTag)
        : Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        title: const Text('Edit Note'),
        backgroundColor: scaffoldBgColor,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              final note = _note;
              if (note != null) {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Delete Note'),
                    content: const Text('Are you sure you want to delete this note?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: TextButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                );

                if (confirm == true) {
                  _removeListeners();
                  _note = null;
                  await ref.read(notesViewModelProvider.notifier).deleteNote(note.id);
                  if (context.mounted) {
                    Navigator.of(context).pop();
                  }
                }
              }
            },
            icon: const Icon(Icons.delete_outline),
          ),
          IconButton(
            onPressed: () async {
              final bodyText = _isList 
                  ? _checklistItems.map((e) => '${e.isChecked ? '[x]' : '[ ]'} ${e.text}').join('\n')
                  : _bodyController.text;
              final text = '${_titleController.text}\n\n$bodyText'.trim();
              if (text.isEmpty) {
                await showCannotShareEmptyNoteDialog(context);
              } else {
                await SharePlus.instance.share(ShareParams(text: text));
              }
            },
            icon: const Icon(Icons.share),
          )
        ],
      ),
      body: FutureBuilder<Note>(
        future: _createOrGetExistingNote(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done && snapshot.hasData) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                      hintStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  const Divider(),
                  Expanded(
                    child: _isList
                        ? _buildChecklist()
                        : TextField(
                            controller: _bodyController,
                            keyboardType: TextInputType.multiline,
                            maxLines: null,
                            decoration: const InputDecoration(
                              hintText: 'Start typing your note...',
                              border: InputBorder.none,
                            ),
                          ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Color Tag',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 44,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final color = getNoteColor(context, index);
                    final isSelected = (_note?.colorTag ?? 0) == index;
                    return GestureDetector(
                      onTap: () {
                        if (_note == null) return;
                        setState(() {
                          _note = _note!.copyWith(colorTag: index);
                        });
                        ref.read(notesViewModelProvider.notifier).updateNoteContent(
                          _note!.id,
                          _titleController.text,
                          _isList ? ChecklistItem.toJsonList(_checklistItems) : _bodyController.text,
                          index,
                          isList: _isList,
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.outlineVariant,
                            width: isSelected ? 3 : 1,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                    blurRadius: 6,
                                    spreadRadius: 1,
                                  )
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check,
                                size: 18,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
