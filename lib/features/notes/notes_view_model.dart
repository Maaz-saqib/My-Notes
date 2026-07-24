import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import 'notes_repository.dart';
import '../../core/database/app_database.dart';

part 'notes_view_model.g.dart';

@riverpod
class NotesViewModel extends _$NotesViewModel {
  @override
  Stream<List<Note>> build() {
    return ref.watch(notesRepositoryProvider).watchAll();
  }

  Future<int> addNote(String title, String body, int colorTag, {bool isList = false}) async {
    try {
      return await ref.read(notesRepositoryProvider).add(
        NotesCompanion.insert(
          title: title,
          body: body,
          colorTag: Value(colorTag),
          isList: Value(isList),
          updatedAt: DateTime.now(),
        ),
      );
    } catch (e, stack) {
      debugPrint('NotesViewModel.addNote error: $e\n$stack');
      rethrow;
    }
  }

  Future<void> updateNoteContent(int id, String title, String body, int colorTag, {bool isList = false}) async {
    try {
      await ref.read(notesRepositoryProvider).updateNote(
        id,
        NotesCompanion(
          title: Value(title),
          body: Value(body),
          colorTag: Value(colorTag),
          isList: Value(isList),
          updatedAt: Value(DateTime.now()),
        ),
      );
    } catch (e, stack) {
      debugPrint('NotesViewModel.updateNoteContent error: $e\n$stack');
      rethrow;
    }
  }

  Future<void> deleteNote(int id) async {
    try {
      await ref.read(notesRepositoryProvider).delete(id);
    } catch (e, stack) {
      debugPrint('NotesViewModel.deleteNote error: $e\n$stack');
      rethrow;
    }
  }

  Future<int> restoreNote(Note note) async {
    try {
      return await ref.read(notesRepositoryProvider).add(
        NotesCompanion.insert(
          title: note.title,
          body: note.body,
          colorTag: Value(note.colorTag),
          isList: Value(note.isList),
          updatedAt: note.updatedAt,
        ),
      );
    } catch (e, stack) {
      debugPrint('NotesViewModel.restoreNote error: $e\n$stack');
      rethrow;
    }
  }

  Future<Note?> getNoteById(int id) async {
    try {
      return await ref.read(notesRepositoryProvider).getNote(id);
    } catch (e, stack) {
      debugPrint('NotesViewModel.getNoteById error: $e\n$stack');
      return null;
    }
  }
}
