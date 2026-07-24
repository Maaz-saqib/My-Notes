import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Notes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get body => text()();
  IntColumn get colorTag => integer().withDefault(const Constant(0))();
  BoolColumn get isList => boolean().withDefault(const Constant(false))();
  DateTimeColumn get updatedAt => dateTime()();
}

class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  IntColumn get colorTag => integer().withDefault(const Constant(0))();
  BoolColumn get hasAlarm => boolean().withDefault(const Constant(false))();
  TextColumn get alarmSound => text().withDefault(const Constant('default'))();
  DateTimeColumn get updatedAt => dateTime()();
}

class PomodoroSessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get startTime => dateTime()();
  DateTimeColumn get endTime => dateTime()();
  IntColumn get durationMinutes => integer()();
  TextColumn get mode => text()(); // 'focus', 'break', or 'open'
}

class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text().nullable()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(tables: [Notes, Todos, PomodoroSessions, Settings])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(notes, notes.isList);
          }
          if (from < 3) {
            await m.addColumn(todos, todos.hasAlarm);
            await m.addColumn(todos, todos.alarmSound);
          }
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'tick_notes_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
