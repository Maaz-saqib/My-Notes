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

  Future<int> addNote(String title, String body, int colorTag, {bool isList = false}) {
    return ref.read(notesRepositoryProvider).add(
      NotesCompanion.insert(
        title: title,
        body: body,
        colorTag: Value(colorTag),
        isList: Value(isList),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> updateNoteContent(int id, String title, String body, int colorTag, {bool isList = false}) {
    return ref.read(notesRepositoryProvider).updateNote(
      id,
      NotesCompanion(
        title: Value(title),
        body: Value(body),
        colorTag: Value(colorTag),
        isList: Value(isList),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<void> deleteNote(int id) {
    return ref.read(notesRepositoryProvider).delete(id);
  }

  Future<int> restoreNote(Note note) {
    return ref.read(notesRepositoryProvider).add(
      NotesCompanion.insert(
        title: note.title,
        body: note.body,
        colorTag: Value(note.colorTag),
        isList: Value(note.isList),
        updatedAt: note.updatedAt,
      ),
    );
  }

  Future<Note?> getNoteById(int id) {
    return ref.read(notesRepositoryProvider).getNote(id);
  }
}
