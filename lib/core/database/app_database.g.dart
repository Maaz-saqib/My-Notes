// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $NotesTable extends Notes with TableInfo<$NotesTable, Note>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$NotesTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
static const VerificationMeta _titleMeta = const VerificationMeta('title');
@override
late final GeneratedColumn<String> title = GeneratedColumn<String>('title', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _bodyMeta = const VerificationMeta('body');
@override
late final GeneratedColumn<String> body = GeneratedColumn<String>('body', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _colorTagMeta = const VerificationMeta('colorTag');
@override
late final GeneratedColumn<int> colorTag = GeneratedColumn<int>('color_tag', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(0));
static const VerificationMeta _isListMeta = const VerificationMeta('isList');
@override
late final GeneratedColumn<bool> isList = GeneratedColumn<bool>('is_list', aliasedName, false, type: DriftSqlType.bool, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_list" IN (0, 1))'), defaultValue: const Constant(false));
static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
@override
late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>('updated_at', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
@override
List<GeneratedColumn> get $columns => [id, title, body, colorTag, isList, updatedAt];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'notes';
@override
VerificationContext validateIntegrity(Insertable<Note> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('title')) {
context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));} else if (isInserting) {
context.missing(_titleMeta);
}
if (data.containsKey('body')) {
context.handle(_bodyMeta, body.isAcceptableOrUnknown(data['body']!, _bodyMeta));} else if (isInserting) {
context.missing(_bodyMeta);
}
if (data.containsKey('color_tag')) {
context.handle(_colorTagMeta, colorTag.isAcceptableOrUnknown(data['color_tag']!, _colorTagMeta));}if (data.containsKey('is_list')) {
context.handle(_isListMeta, isList.isAcceptableOrUnknown(data['is_list']!, _isListMeta));}if (data.containsKey('updated_at')) {
context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));} else if (isInserting) {
context.missing(_updatedAtMeta);
}
return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override Note map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return Note(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!, body: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}body'])!, colorTag: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}color_tag'])!, isList: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_list'])!, updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!, );
}
@override
$NotesTable createAlias(String alias) {
return $NotesTable(attachedDatabase, alias);}}class Note extends DataClass implements Insertable<Note> 
{
final int id;
final String title;
final String body;
final int colorTag;
final bool isList;
final DateTime updatedAt;
const Note({required this.id, required this.title, required this.body, required this.colorTag, required this.isList, required this.updatedAt});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
map['title'] = Variable<String>(title);
map['body'] = Variable<String>(body);
map['color_tag'] = Variable<int>(colorTag);
map['is_list'] = Variable<bool>(isList);
map['updated_at'] = Variable<DateTime>(updatedAt);
return map; 
}
NotesCompanion toCompanion(bool nullToAbsent) {
return NotesCompanion(id: Value(id),title: Value(title),body: Value(body),colorTag: Value(colorTag),isList: Value(isList),updatedAt: Value(updatedAt),);
}
factory Note.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return Note(id: serializer.fromJson<int>(json['id']),title: serializer.fromJson<String>(json['title']),body: serializer.fromJson<String>(json['body']),colorTag: serializer.fromJson<int>(json['colorTag']),isList: serializer.fromJson<bool>(json['isList']),updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'title': serializer.toJson<String>(title),'body': serializer.toJson<String>(body),'colorTag': serializer.toJson<int>(colorTag),'isList': serializer.toJson<bool>(isList),'updatedAt': serializer.toJson<DateTime>(updatedAt),};}Note copyWith({int? id,String? title,String? body,int? colorTag,bool? isList,DateTime? updatedAt}) => Note(id: id ?? this.id,title: title ?? this.title,body: body ?? this.body,colorTag: colorTag ?? this.colorTag,isList: isList ?? this.isList,updatedAt: updatedAt ?? this.updatedAt,);Note copyWithCompanion(NotesCompanion data) {
return Note(
id: data.id.present ? data.id.value : this.id,title: data.title.present ? data.title.value : this.title,body: data.body.present ? data.body.value : this.body,colorTag: data.colorTag.present ? data.colorTag.value : this.colorTag,isList: data.isList.present ? data.isList.value : this.isList,updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,);
}
@override
String toString() {return (StringBuffer('Note(')..write('id: $id, ')..write('title: $title, ')..write('body: $body, ')..write('colorTag: $colorTag, ')..write('isList: $isList, ')..write('updatedAt: $updatedAt')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, title, body, colorTag, isList, updatedAt);@override
bool operator ==(Object other) => identical(this, other) || (other is Note && other.id == this.id && other.title == this.title && other.body == this.body && other.colorTag == this.colorTag && other.isList == this.isList && other.updatedAt == this.updatedAt);
}class NotesCompanion extends UpdateCompanion<Note> {
final Value<int> id;
final Value<String> title;
final Value<String> body;
final Value<int> colorTag;
final Value<bool> isList;
final Value<DateTime> updatedAt;
const NotesCompanion({this.id = const Value.absent(),this.title = const Value.absent(),this.body = const Value.absent(),this.colorTag = const Value.absent(),this.isList = const Value.absent(),this.updatedAt = const Value.absent(),});
NotesCompanion.insert({this.id = const Value.absent(),required String title,required String body,this.colorTag = const Value.absent(),this.isList = const Value.absent(),required DateTime updatedAt,}): title = Value(title), body = Value(body), updatedAt = Value(updatedAt);
static Insertable<Note> custom({Expression<int>? id, 
Expression<String>? title, 
Expression<String>? body, 
Expression<int>? colorTag, 
Expression<bool>? isList, 
Expression<DateTime>? updatedAt, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (title != null)'title': title,if (body != null)'body': body,if (colorTag != null)'color_tag': colorTag,if (isList != null)'is_list': isList,if (updatedAt != null)'updated_at': updatedAt,});
}NotesCompanion copyWith({Value<int>? id, Value<String>? title, Value<String>? body, Value<int>? colorTag, Value<bool>? isList, Value<DateTime>? updatedAt}) {
return NotesCompanion(id: id ?? this.id,title: title ?? this.title,body: body ?? this.body,colorTag: colorTag ?? this.colorTag,isList: isList ?? this.isList,updatedAt: updatedAt ?? this.updatedAt,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<int>(id.value);}
if (title.present) {
map['title'] = Variable<String>(title.value);}
if (body.present) {
map['body'] = Variable<String>(body.value);}
if (colorTag.present) {
map['color_tag'] = Variable<int>(colorTag.value);}
if (isList.present) {
map['is_list'] = Variable<bool>(isList.value);}
if (updatedAt.present) {
map['updated_at'] = Variable<DateTime>(updatedAt.value);}
return map; 
}
@override
String toString() {return (StringBuffer('NotesCompanion(')..write('id: $id, ')..write('title: $title, ')..write('body: $body, ')..write('colorTag: $colorTag, ')..write('isList: $isList, ')..write('updatedAt: $updatedAt')..write(')')).toString();}
}
class $TodosTable extends Todos with TableInfo<$TodosTable, Todo>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$TodosTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
static const VerificationMeta _titleMeta = const VerificationMeta('title');
@override
late final GeneratedColumn<String> title = GeneratedColumn<String>('title', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _dueDateMeta = const VerificationMeta('dueDate');
@override
late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>('due_date', aliasedName, true, type: DriftSqlType.dateTime, requiredDuringInsert: false);
static const VerificationMeta _isCompletedMeta = const VerificationMeta('isCompleted');
@override
late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>('is_completed', aliasedName, false, type: DriftSqlType.bool, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('CHECK ("is_completed" IN (0, 1))'), defaultValue: const Constant(false));
static const VerificationMeta _colorTagMeta = const VerificationMeta('colorTag');
@override
late final GeneratedColumn<int> colorTag = GeneratedColumn<int>('color_tag', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: false, defaultValue: const Constant(0));
static const VerificationMeta _updatedAtMeta = const VerificationMeta('updatedAt');
@override
late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>('updated_at', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
@override
List<GeneratedColumn> get $columns => [id, title, dueDate, isCompleted, colorTag, updatedAt];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'todos';
@override
VerificationContext validateIntegrity(Insertable<Todo> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('title')) {
context.handle(_titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));} else if (isInserting) {
context.missing(_titleMeta);
}
if (data.containsKey('due_date')) {
context.handle(_dueDateMeta, dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta));}if (data.containsKey('is_completed')) {
context.handle(_isCompletedMeta, isCompleted.isAcceptableOrUnknown(data['is_completed']!, _isCompletedMeta));}if (data.containsKey('color_tag')) {
context.handle(_colorTagMeta, colorTag.isAcceptableOrUnknown(data['color_tag']!, _colorTagMeta));}if (data.containsKey('updated_at')) {
context.handle(_updatedAtMeta, updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));} else if (isInserting) {
context.missing(_updatedAtMeta);
}
return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override Todo map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return Todo(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, title: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}title'])!, dueDate: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}due_date']), isCompleted: attachedDatabase.typeMapping.read(DriftSqlType.bool, data['${effectivePrefix}is_completed'])!, colorTag: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}color_tag'])!, updatedAt: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!, );
}
@override
$TodosTable createAlias(String alias) {
return $TodosTable(attachedDatabase, alias);}}class Todo extends DataClass implements Insertable<Todo> 
{
final int id;
final String title;
final DateTime? dueDate;
final bool isCompleted;
final int colorTag;
final DateTime updatedAt;
const Todo({required this.id, required this.title, this.dueDate, required this.isCompleted, required this.colorTag, required this.updatedAt});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
map['title'] = Variable<String>(title);
if (!nullToAbsent || dueDate != null){map['due_date'] = Variable<DateTime>(dueDate);
}map['is_completed'] = Variable<bool>(isCompleted);
map['color_tag'] = Variable<int>(colorTag);
map['updated_at'] = Variable<DateTime>(updatedAt);
return map; 
}
TodosCompanion toCompanion(bool nullToAbsent) {
return TodosCompanion(id: Value(id),title: Value(title),dueDate: dueDate == null && nullToAbsent ? const Value.absent() : Value(dueDate),isCompleted: Value(isCompleted),colorTag: Value(colorTag),updatedAt: Value(updatedAt),);
}
factory Todo.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return Todo(id: serializer.fromJson<int>(json['id']),title: serializer.fromJson<String>(json['title']),dueDate: serializer.fromJson<DateTime?>(json['dueDate']),isCompleted: serializer.fromJson<bool>(json['isCompleted']),colorTag: serializer.fromJson<int>(json['colorTag']),updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'title': serializer.toJson<String>(title),'dueDate': serializer.toJson<DateTime?>(dueDate),'isCompleted': serializer.toJson<bool>(isCompleted),'colorTag': serializer.toJson<int>(colorTag),'updatedAt': serializer.toJson<DateTime>(updatedAt),};}Todo copyWith({int? id,String? title,Value<DateTime?> dueDate = const Value.absent(),bool? isCompleted,int? colorTag,DateTime? updatedAt}) => Todo(id: id ?? this.id,title: title ?? this.title,dueDate: dueDate.present ? dueDate.value : this.dueDate,isCompleted: isCompleted ?? this.isCompleted,colorTag: colorTag ?? this.colorTag,updatedAt: updatedAt ?? this.updatedAt,);Todo copyWithCompanion(TodosCompanion data) {
return Todo(
id: data.id.present ? data.id.value : this.id,title: data.title.present ? data.title.value : this.title,dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,isCompleted: data.isCompleted.present ? data.isCompleted.value : this.isCompleted,colorTag: data.colorTag.present ? data.colorTag.value : this.colorTag,updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,);
}
@override
String toString() {return (StringBuffer('Todo(')..write('id: $id, ')..write('title: $title, ')..write('dueDate: $dueDate, ')..write('isCompleted: $isCompleted, ')..write('colorTag: $colorTag, ')..write('updatedAt: $updatedAt')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, title, dueDate, isCompleted, colorTag, updatedAt);@override
bool operator ==(Object other) => identical(this, other) || (other is Todo && other.id == this.id && other.title == this.title && other.dueDate == this.dueDate && other.isCompleted == this.isCompleted && other.colorTag == this.colorTag && other.updatedAt == this.updatedAt);
}class TodosCompanion extends UpdateCompanion<Todo> {
final Value<int> id;
final Value<String> title;
final Value<DateTime?> dueDate;
final Value<bool> isCompleted;
final Value<int> colorTag;
final Value<DateTime> updatedAt;
const TodosCompanion({this.id = const Value.absent(),this.title = const Value.absent(),this.dueDate = const Value.absent(),this.isCompleted = const Value.absent(),this.colorTag = const Value.absent(),this.updatedAt = const Value.absent(),});
TodosCompanion.insert({this.id = const Value.absent(),required String title,this.dueDate = const Value.absent(),this.isCompleted = const Value.absent(),this.colorTag = const Value.absent(),required DateTime updatedAt,}): title = Value(title), updatedAt = Value(updatedAt);
static Insertable<Todo> custom({Expression<int>? id, 
Expression<String>? title, 
Expression<DateTime>? dueDate, 
Expression<bool>? isCompleted, 
Expression<int>? colorTag, 
Expression<DateTime>? updatedAt, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (title != null)'title': title,if (dueDate != null)'due_date': dueDate,if (isCompleted != null)'is_completed': isCompleted,if (colorTag != null)'color_tag': colorTag,if (updatedAt != null)'updated_at': updatedAt,});
}TodosCompanion copyWith({Value<int>? id, Value<String>? title, Value<DateTime?>? dueDate, Value<bool>? isCompleted, Value<int>? colorTag, Value<DateTime>? updatedAt}) {
return TodosCompanion(id: id ?? this.id,title: title ?? this.title,dueDate: dueDate ?? this.dueDate,isCompleted: isCompleted ?? this.isCompleted,colorTag: colorTag ?? this.colorTag,updatedAt: updatedAt ?? this.updatedAt,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<int>(id.value);}
if (title.present) {
map['title'] = Variable<String>(title.value);}
if (dueDate.present) {
map['due_date'] = Variable<DateTime>(dueDate.value);}
if (isCompleted.present) {
map['is_completed'] = Variable<bool>(isCompleted.value);}
if (colorTag.present) {
map['color_tag'] = Variable<int>(colorTag.value);}
if (updatedAt.present) {
map['updated_at'] = Variable<DateTime>(updatedAt.value);}
return map; 
}
@override
String toString() {return (StringBuffer('TodosCompanion(')..write('id: $id, ')..write('title: $title, ')..write('dueDate: $dueDate, ')..write('isCompleted: $isCompleted, ')..write('colorTag: $colorTag, ')..write('updatedAt: $updatedAt')..write(')')).toString();}
}
class $PomodoroSessionsTable extends PomodoroSessions with TableInfo<$PomodoroSessionsTable, PomodoroSession>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$PomodoroSessionsTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _idMeta = const VerificationMeta('id');
@override
late final GeneratedColumn<int> id = GeneratedColumn<int>('id', aliasedName, false, hasAutoIncrement: true, type: DriftSqlType.int, requiredDuringInsert: false, defaultConstraints: GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
static const VerificationMeta _startTimeMeta = const VerificationMeta('startTime');
@override
late final GeneratedColumn<DateTime> startTime = GeneratedColumn<DateTime>('start_time', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
static const VerificationMeta _endTimeMeta = const VerificationMeta('endTime');
@override
late final GeneratedColumn<DateTime> endTime = GeneratedColumn<DateTime>('end_time', aliasedName, false, type: DriftSqlType.dateTime, requiredDuringInsert: true);
static const VerificationMeta _durationMinutesMeta = const VerificationMeta('durationMinutes');
@override
late final GeneratedColumn<int> durationMinutes = GeneratedColumn<int>('duration_minutes', aliasedName, false, type: DriftSqlType.int, requiredDuringInsert: true);
static const VerificationMeta _modeMeta = const VerificationMeta('mode');
@override
late final GeneratedColumn<String> mode = GeneratedColumn<String>('mode', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
@override
List<GeneratedColumn> get $columns => [id, startTime, endTime, durationMinutes, mode];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'pomodoro_sessions';
@override
VerificationContext validateIntegrity(Insertable<PomodoroSession> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('id')) {
context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));}if (data.containsKey('start_time')) {
context.handle(_startTimeMeta, startTime.isAcceptableOrUnknown(data['start_time']!, _startTimeMeta));} else if (isInserting) {
context.missing(_startTimeMeta);
}
if (data.containsKey('end_time')) {
context.handle(_endTimeMeta, endTime.isAcceptableOrUnknown(data['end_time']!, _endTimeMeta));} else if (isInserting) {
context.missing(_endTimeMeta);
}
if (data.containsKey('duration_minutes')) {
context.handle(_durationMinutesMeta, durationMinutes.isAcceptableOrUnknown(data['duration_minutes']!, _durationMinutesMeta));} else if (isInserting) {
context.missing(_durationMinutesMeta);
}
if (data.containsKey('mode')) {
context.handle(_modeMeta, mode.isAcceptableOrUnknown(data['mode']!, _modeMeta));} else if (isInserting) {
context.missing(_modeMeta);
}
return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {id};
@override PomodoroSession map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return PomodoroSession(id: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}id'])!, startTime: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}start_time'])!, endTime: attachedDatabase.typeMapping.read(DriftSqlType.dateTime, data['${effectivePrefix}end_time'])!, durationMinutes: attachedDatabase.typeMapping.read(DriftSqlType.int, data['${effectivePrefix}duration_minutes'])!, mode: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}mode'])!, );
}
@override
$PomodoroSessionsTable createAlias(String alias) {
return $PomodoroSessionsTable(attachedDatabase, alias);}}class PomodoroSession extends DataClass implements Insertable<PomodoroSession> 
{
final int id;
final DateTime startTime;
final DateTime endTime;
final int durationMinutes;
final String mode;
const PomodoroSession({required this.id, required this.startTime, required this.endTime, required this.durationMinutes, required this.mode});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['id'] = Variable<int>(id);
map['start_time'] = Variable<DateTime>(startTime);
map['end_time'] = Variable<DateTime>(endTime);
map['duration_minutes'] = Variable<int>(durationMinutes);
map['mode'] = Variable<String>(mode);
return map; 
}
PomodoroSessionsCompanion toCompanion(bool nullToAbsent) {
return PomodoroSessionsCompanion(id: Value(id),startTime: Value(startTime),endTime: Value(endTime),durationMinutes: Value(durationMinutes),mode: Value(mode),);
}
factory PomodoroSession.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return PomodoroSession(id: serializer.fromJson<int>(json['id']),startTime: serializer.fromJson<DateTime>(json['startTime']),endTime: serializer.fromJson<DateTime>(json['endTime']),durationMinutes: serializer.fromJson<int>(json['durationMinutes']),mode: serializer.fromJson<String>(json['mode']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'id': serializer.toJson<int>(id),'startTime': serializer.toJson<DateTime>(startTime),'endTime': serializer.toJson<DateTime>(endTime),'durationMinutes': serializer.toJson<int>(durationMinutes),'mode': serializer.toJson<String>(mode),};}PomodoroSession copyWith({int? id,DateTime? startTime,DateTime? endTime,int? durationMinutes,String? mode}) => PomodoroSession(id: id ?? this.id,startTime: startTime ?? this.startTime,endTime: endTime ?? this.endTime,durationMinutes: durationMinutes ?? this.durationMinutes,mode: mode ?? this.mode,);PomodoroSession copyWithCompanion(PomodoroSessionsCompanion data) {
return PomodoroSession(
id: data.id.present ? data.id.value : this.id,startTime: data.startTime.present ? data.startTime.value : this.startTime,endTime: data.endTime.present ? data.endTime.value : this.endTime,durationMinutes: data.durationMinutes.present ? data.durationMinutes.value : this.durationMinutes,mode: data.mode.present ? data.mode.value : this.mode,);
}
@override
String toString() {return (StringBuffer('PomodoroSession(')..write('id: $id, ')..write('startTime: $startTime, ')..write('endTime: $endTime, ')..write('durationMinutes: $durationMinutes, ')..write('mode: $mode')..write(')')).toString();}
@override
 int get hashCode => Object.hash(id, startTime, endTime, durationMinutes, mode);@override
bool operator ==(Object other) => identical(this, other) || (other is PomodoroSession && other.id == this.id && other.startTime == this.startTime && other.endTime == this.endTime && other.durationMinutes == this.durationMinutes && other.mode == this.mode);
}class PomodoroSessionsCompanion extends UpdateCompanion<PomodoroSession> {
final Value<int> id;
final Value<DateTime> startTime;
final Value<DateTime> endTime;
final Value<int> durationMinutes;
final Value<String> mode;
const PomodoroSessionsCompanion({this.id = const Value.absent(),this.startTime = const Value.absent(),this.endTime = const Value.absent(),this.durationMinutes = const Value.absent(),this.mode = const Value.absent(),});
PomodoroSessionsCompanion.insert({this.id = const Value.absent(),required DateTime startTime,required DateTime endTime,required int durationMinutes,required String mode,}): startTime = Value(startTime), endTime = Value(endTime), durationMinutes = Value(durationMinutes), mode = Value(mode);
static Insertable<PomodoroSession> custom({Expression<int>? id, 
Expression<DateTime>? startTime, 
Expression<DateTime>? endTime, 
Expression<int>? durationMinutes, 
Expression<String>? mode, 
}) {
return RawValuesInsertable({if (id != null)'id': id,if (startTime != null)'start_time': startTime,if (endTime != null)'end_time': endTime,if (durationMinutes != null)'duration_minutes': durationMinutes,if (mode != null)'mode': mode,});
}PomodoroSessionsCompanion copyWith({Value<int>? id, Value<DateTime>? startTime, Value<DateTime>? endTime, Value<int>? durationMinutes, Value<String>? mode}) {
return PomodoroSessionsCompanion(id: id ?? this.id,startTime: startTime ?? this.startTime,endTime: endTime ?? this.endTime,durationMinutes: durationMinutes ?? this.durationMinutes,mode: mode ?? this.mode,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (id.present) {
map['id'] = Variable<int>(id.value);}
if (startTime.present) {
map['start_time'] = Variable<DateTime>(startTime.value);}
if (endTime.present) {
map['end_time'] = Variable<DateTime>(endTime.value);}
if (durationMinutes.present) {
map['duration_minutes'] = Variable<int>(durationMinutes.value);}
if (mode.present) {
map['mode'] = Variable<String>(mode.value);}
return map; 
}
@override
String toString() {return (StringBuffer('PomodoroSessionsCompanion(')..write('id: $id, ')..write('startTime: $startTime, ')..write('endTime: $endTime, ')..write('durationMinutes: $durationMinutes, ')..write('mode: $mode')..write(')')).toString();}
}
class $SettingsTable extends Settings with TableInfo<$SettingsTable, Setting>{
@override final GeneratedDatabase attachedDatabase;
final String? _alias;
$SettingsTable(this.attachedDatabase, [this._alias]);
static const VerificationMeta _keyMeta = const VerificationMeta('key');
@override
late final GeneratedColumn<String> key = GeneratedColumn<String>('key', aliasedName, false, type: DriftSqlType.string, requiredDuringInsert: true);
static const VerificationMeta _valueMeta = const VerificationMeta('value');
@override
late final GeneratedColumn<String> value = GeneratedColumn<String>('value', aliasedName, true, type: DriftSqlType.string, requiredDuringInsert: false);
@override
List<GeneratedColumn> get $columns => [key, value];
@override
String get aliasedName => _alias ?? actualTableName;
@override
 String get actualTableName => $name;
static const String $name = 'settings';
@override
VerificationContext validateIntegrity(Insertable<Setting> instance, {bool isInserting = false}) {
final context = VerificationContext();
final data = instance.toColumns(true);
if (data.containsKey('key')) {
context.handle(_keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));} else if (isInserting) {
context.missing(_keyMeta);
}
if (data.containsKey('value')) {
context.handle(_valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));}return context;
}
@override
Set<GeneratedColumn> get $primaryKey => {key};
@override Setting map(Map<String, dynamic> data, {String? tablePrefix})  {
final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';return Setting(key: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}key'])!, value: attachedDatabase.typeMapping.read(DriftSqlType.string, data['${effectivePrefix}value']), );
}
@override
$SettingsTable createAlias(String alias) {
return $SettingsTable(attachedDatabase, alias);}}class Setting extends DataClass implements Insertable<Setting> 
{
final String key;
final String? value;
const Setting({required this.key, this.value});@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};map['key'] = Variable<String>(key);
if (!nullToAbsent || value != null){map['value'] = Variable<String>(value);
}return map; 
}
SettingsCompanion toCompanion(bool nullToAbsent) {
return SettingsCompanion(key: Value(key),value: value == null && nullToAbsent ? const Value.absent() : Value(value),);
}
factory Setting.fromJson(Map<String, dynamic> json, {ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return Setting(key: serializer.fromJson<String>(json['key']),value: serializer.fromJson<String?>(json['value']),);}
@override Map<String, dynamic> toJson({ValueSerializer? serializer}) {
serializer ??= driftRuntimeOptions.defaultSerializer;
return <String, dynamic>{
'key': serializer.toJson<String>(key),'value': serializer.toJson<String?>(value),};}Setting copyWith({String? key,Value<String?> value = const Value.absent()}) => Setting(key: key ?? this.key,value: value.present ? value.value : this.value,);Setting copyWithCompanion(SettingsCompanion data) {
return Setting(
key: data.key.present ? data.key.value : this.key,value: data.value.present ? data.value.value : this.value,);
}
@override
String toString() {return (StringBuffer('Setting(')..write('key: $key, ')..write('value: $value')..write(')')).toString();}
@override
 int get hashCode => Object.hash(key, value);@override
bool operator ==(Object other) => identical(this, other) || (other is Setting && other.key == this.key && other.value == this.value);
}class SettingsCompanion extends UpdateCompanion<Setting> {
final Value<String> key;
final Value<String?> value;
final Value<int> rowid;
const SettingsCompanion({this.key = const Value.absent(),this.value = const Value.absent(),this.rowid = const Value.absent(),});
SettingsCompanion.insert({required String key,this.value = const Value.absent(),this.rowid = const Value.absent(),}): key = Value(key);
static Insertable<Setting> custom({Expression<String>? key, 
Expression<String>? value, 
Expression<int>? rowid, 
}) {
return RawValuesInsertable({if (key != null)'key': key,if (value != null)'value': value,if (rowid != null)'rowid': rowid,});
}SettingsCompanion copyWith({Value<String>? key, Value<String?>? value, Value<int>? rowid}) {
return SettingsCompanion(key: key ?? this.key,value: value ?? this.value,rowid: rowid ?? this.rowid,);
}
@override
Map<String, Expression> toColumns(bool nullToAbsent) {
final map = <String, Expression> {};if (key.present) {
map['key'] = Variable<String>(key.value);}
if (value.present) {
map['value'] = Variable<String>(value.value);}
if (rowid.present) {
map['rowid'] = Variable<int>(rowid.value);}
return map; 
}
@override
String toString() {return (StringBuffer('SettingsCompanion(')..write('key: $key, ')..write('value: $value, ')..write('rowid: $rowid')..write(')')).toString();}
}
abstract class _$AppDatabase extends GeneratedDatabase{
_$AppDatabase(QueryExecutor e): super(e);
$AppDatabaseManager get managers => $AppDatabaseManager(this);
late final $NotesTable notes = $NotesTable(this);
late final $TodosTable todos = $TodosTable(this);
late final $PomodoroSessionsTable pomodoroSessions = $PomodoroSessionsTable(this);
late final $SettingsTable settings = $SettingsTable(this);
@override
Iterable<TableInfo<Table, Object?>> get allTables => allSchemaEntities.whereType<TableInfo<Table, Object?>>();
@override
List<DatabaseSchemaEntity> get allSchemaEntities => [notes, todos, pomodoroSessions, settings];
}
typedef $$NotesTableCreateCompanionBuilder = NotesCompanion Function({Value<int> id,required String title,required String body,Value<int> colorTag,Value<bool> isList,required DateTime updatedAt,});
typedef $$NotesTableUpdateCompanionBuilder = NotesCompanion Function({Value<int> id,Value<String> title,Value<String> body,Value<int> colorTag,Value<bool> isList,Value<DateTime> updatedAt,});
class $$NotesTableFilterComposer extends Composer<
        _$AppDatabase,
        $NotesTable> {
        $$NotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get title => $composableBuilder(
      column: $table.title,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get body => $composableBuilder(
      column: $table.body,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get colorTag => $composableBuilder(
      column: $table.colorTag,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<bool> get isList => $composableBuilder(
      column: $table.isList,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt,
      builder: (column) => 
      ColumnFilters(column));
      
        }
      class $$NotesTableOrderingComposer extends Composer<
        _$AppDatabase,
        $NotesTable> {
        $$NotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get body => $composableBuilder(
      column: $table.body,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get colorTag => $composableBuilder(
      column: $table.colorTag,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<bool> get isList => $composableBuilder(
      column: $table.isList,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt,
      builder: (column) => 
      ColumnOrderings(column));
      
        }
      class $$NotesTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $NotesTable> {
        $$NotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<String> get title => $composableBuilder(
      column: $table.title,
      builder: (column) => column);
      
GeneratedColumn<String> get body => $composableBuilder(
      column: $table.body,
      builder: (column) => column);
      
GeneratedColumn<int> get colorTag => $composableBuilder(
      column: $table.colorTag,
      builder: (column) => column);
      
GeneratedColumn<bool> get isList => $composableBuilder(
      column: $table.isList,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt,
      builder: (column) => column);
      
        }
      class $$NotesTableTableManager extends RootTableManager    <_$AppDatabase,
    $NotesTable,
    Note,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (Note,BaseReferences<_$AppDatabase,$NotesTable,Note>),
    Note,
    PrefetchHooks Function()
    > {
    $$NotesTableTableManager(_$AppDatabase db, $NotesTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$NotesTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$NotesTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$NotesTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<String> title = const Value.absent(),Value<String> body = const Value.absent(),Value<int> colorTag = const Value.absent(),Value<bool> isList = const Value.absent(),Value<DateTime> updatedAt = const Value.absent(),})=> NotesCompanion(id: id,title: title,body: body,colorTag: colorTag,isList: isList,updatedAt: updatedAt,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),required String title,required String body,Value<int> colorTag = const Value.absent(),Value<bool> isList = const Value.absent(),required DateTime updatedAt,})=> NotesCompanion.insert(id: id,title: title,body: body,colorTag: colorTag,isList: isList,updatedAt: updatedAt,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$NotesTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $NotesTable,
    Note,
    $$NotesTableFilterComposer,
    $$NotesTableOrderingComposer,
    $$NotesTableAnnotationComposer,
    $$NotesTableCreateCompanionBuilder,
    $$NotesTableUpdateCompanionBuilder,
    (Note,BaseReferences<_$AppDatabase,$NotesTable,Note>),
    Note,
    PrefetchHooks Function()
    >;typedef $$TodosTableCreateCompanionBuilder = TodosCompanion Function({Value<int> id,required String title,Value<DateTime?> dueDate,Value<bool> isCompleted,Value<int> colorTag,required DateTime updatedAt,});
typedef $$TodosTableUpdateCompanionBuilder = TodosCompanion Function({Value<int> id,Value<String> title,Value<DateTime?> dueDate,Value<bool> isCompleted,Value<int> colorTag,Value<DateTime> updatedAt,});
class $$TodosTableFilterComposer extends Composer<
        _$AppDatabase,
        $TodosTable> {
        $$TodosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get title => $composableBuilder(
      column: $table.title,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get colorTag => $composableBuilder(
      column: $table.colorTag,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt,
      builder: (column) => 
      ColumnFilters(column));
      
        }
      class $$TodosTableOrderingComposer extends Composer<
        _$AppDatabase,
        $TodosTable> {
        $$TodosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get colorTag => $composableBuilder(
      column: $table.colorTag,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt,
      builder: (column) => 
      ColumnOrderings(column));
      
        }
      class $$TodosTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $TodosTable> {
        $$TodosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<String> get title => $composableBuilder(
      column: $table.title,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get dueDate => $composableBuilder(
      column: $table.dueDate,
      builder: (column) => column);
      
GeneratedColumn<bool> get isCompleted => $composableBuilder(
      column: $table.isCompleted,
      builder: (column) => column);
      
GeneratedColumn<int> get colorTag => $composableBuilder(
      column: $table.colorTag,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt,
      builder: (column) => column);
      
        }
      class $$TodosTableTableManager extends RootTableManager    <_$AppDatabase,
    $TodosTable,
    Todo,
    $$TodosTableFilterComposer,
    $$TodosTableOrderingComposer,
    $$TodosTableAnnotationComposer,
    $$TodosTableCreateCompanionBuilder,
    $$TodosTableUpdateCompanionBuilder,
    (Todo,BaseReferences<_$AppDatabase,$TodosTable,Todo>),
    Todo,
    PrefetchHooks Function()
    > {
    $$TodosTableTableManager(_$AppDatabase db, $TodosTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$TodosTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$TodosTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$TodosTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<String> title = const Value.absent(),Value<DateTime?> dueDate = const Value.absent(),Value<bool> isCompleted = const Value.absent(),Value<int> colorTag = const Value.absent(),Value<DateTime> updatedAt = const Value.absent(),})=> TodosCompanion(id: id,title: title,dueDate: dueDate,isCompleted: isCompleted,colorTag: colorTag,updatedAt: updatedAt,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),required String title,Value<DateTime?> dueDate = const Value.absent(),Value<bool> isCompleted = const Value.absent(),Value<int> colorTag = const Value.absent(),required DateTime updatedAt,})=> TodosCompanion.insert(id: id,title: title,dueDate: dueDate,isCompleted: isCompleted,colorTag: colorTag,updatedAt: updatedAt,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$TodosTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $TodosTable,
    Todo,
    $$TodosTableFilterComposer,
    $$TodosTableOrderingComposer,
    $$TodosTableAnnotationComposer,
    $$TodosTableCreateCompanionBuilder,
    $$TodosTableUpdateCompanionBuilder,
    (Todo,BaseReferences<_$AppDatabase,$TodosTable,Todo>),
    Todo,
    PrefetchHooks Function()
    >;typedef $$PomodoroSessionsTableCreateCompanionBuilder = PomodoroSessionsCompanion Function({Value<int> id,required DateTime startTime,required DateTime endTime,required int durationMinutes,required String mode,});
typedef $$PomodoroSessionsTableUpdateCompanionBuilder = PomodoroSessionsCompanion Function({Value<int> id,Value<DateTime> startTime,Value<DateTime> endTime,Value<int> durationMinutes,Value<String> mode,});
class $$PomodoroSessionsTableFilterComposer extends Composer<
        _$AppDatabase,
        $PomodoroSessionsTable> {
        $$PomodoroSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get startTime => $composableBuilder(
      column: $table.startTime,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<DateTime> get endTime => $composableBuilder(
      column: $table.endTime,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get mode => $composableBuilder(
      column: $table.mode,
      builder: (column) => 
      ColumnFilters(column));
      
        }
      class $$PomodoroSessionsTableOrderingComposer extends Composer<
        _$AppDatabase,
        $PomodoroSessionsTable> {
        $$PomodoroSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get startTime => $composableBuilder(
      column: $table.startTime,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<DateTime> get endTime => $composableBuilder(
      column: $table.endTime,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get mode => $composableBuilder(
      column: $table.mode,
      builder: (column) => 
      ColumnOrderings(column));
      
        }
      class $$PomodoroSessionsTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $PomodoroSessionsTable> {
        $$PomodoroSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<int> get id => $composableBuilder(
      column: $table.id,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get startTime => $composableBuilder(
      column: $table.startTime,
      builder: (column) => column);
      
GeneratedColumn<DateTime> get endTime => $composableBuilder(
      column: $table.endTime,
      builder: (column) => column);
      
GeneratedColumn<int> get durationMinutes => $composableBuilder(
      column: $table.durationMinutes,
      builder: (column) => column);
      
GeneratedColumn<String> get mode => $composableBuilder(
      column: $table.mode,
      builder: (column) => column);
      
        }
      class $$PomodoroSessionsTableTableManager extends RootTableManager    <_$AppDatabase,
    $PomodoroSessionsTable,
    PomodoroSession,
    $$PomodoroSessionsTableFilterComposer,
    $$PomodoroSessionsTableOrderingComposer,
    $$PomodoroSessionsTableAnnotationComposer,
    $$PomodoroSessionsTableCreateCompanionBuilder,
    $$PomodoroSessionsTableUpdateCompanionBuilder,
    (PomodoroSession,BaseReferences<_$AppDatabase,$PomodoroSessionsTable,PomodoroSession>),
    PomodoroSession,
    PrefetchHooks Function()
    > {
    $$PomodoroSessionsTableTableManager(_$AppDatabase db, $PomodoroSessionsTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$PomodoroSessionsTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$PomodoroSessionsTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$PomodoroSessionsTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<int> id = const Value.absent(),Value<DateTime> startTime = const Value.absent(),Value<DateTime> endTime = const Value.absent(),Value<int> durationMinutes = const Value.absent(),Value<String> mode = const Value.absent(),})=> PomodoroSessionsCompanion(id: id,startTime: startTime,endTime: endTime,durationMinutes: durationMinutes,mode: mode,),
        createCompanionCallback: ({Value<int> id = const Value.absent(),required DateTime startTime,required DateTime endTime,required int durationMinutes,required String mode,})=> PomodoroSessionsCompanion.insert(id: id,startTime: startTime,endTime: endTime,durationMinutes: durationMinutes,mode: mode,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$PomodoroSessionsTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $PomodoroSessionsTable,
    PomodoroSession,
    $$PomodoroSessionsTableFilterComposer,
    $$PomodoroSessionsTableOrderingComposer,
    $$PomodoroSessionsTableAnnotationComposer,
    $$PomodoroSessionsTableCreateCompanionBuilder,
    $$PomodoroSessionsTableUpdateCompanionBuilder,
    (PomodoroSession,BaseReferences<_$AppDatabase,$PomodoroSessionsTable,PomodoroSession>),
    PomodoroSession,
    PrefetchHooks Function()
    >;typedef $$SettingsTableCreateCompanionBuilder = SettingsCompanion Function({required String key,Value<String?> value,Value<int> rowid,});
typedef $$SettingsTableUpdateCompanionBuilder = SettingsCompanion Function({Value<String> key,Value<String?> value,Value<int> rowid,});
class $$SettingsTableFilterComposer extends Composer<
        _$AppDatabase,
        $SettingsTable> {
        $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnFilters<String> get key => $composableBuilder(
      column: $table.key,
      builder: (column) => 
      ColumnFilters(column));
      
ColumnFilters<String> get value => $composableBuilder(
      column: $table.value,
      builder: (column) => 
      ColumnFilters(column));
      
        }
      class $$SettingsTableOrderingComposer extends Composer<
        _$AppDatabase,
        $SettingsTable> {
        $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key,
      builder: (column) => 
      ColumnOrderings(column));
      
ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value,
      builder: (column) => 
      ColumnOrderings(column));
      
        }
      class $$SettingsTableAnnotationComposer extends Composer<
        _$AppDatabase,
        $SettingsTable> {
        $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
          GeneratedColumn<String> get key => $composableBuilder(
      column: $table.key,
      builder: (column) => column);
      
GeneratedColumn<String> get value => $composableBuilder(
      column: $table.value,
      builder: (column) => column);
      
        }
      class $$SettingsTableTableManager extends RootTableManager    <_$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting,BaseReferences<_$AppDatabase,$SettingsTable,Setting>),
    Setting,
    PrefetchHooks Function()
    > {
    $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table) : super(
      TableManagerState(
        db: db,
        table: table,
        createFilteringComposer: () => $$SettingsTableFilterComposer($db: db,$table:table),
        createOrderingComposer: () => $$SettingsTableOrderingComposer($db: db,$table:table),
        createComputedFieldComposer: () => $$SettingsTableAnnotationComposer($db: db,$table:table),
        updateCompanionCallback: ({Value<String> key = const Value.absent(),Value<String?> value = const Value.absent(),Value<int> rowid = const Value.absent(),})=> SettingsCompanion(key: key,value: value,rowid: rowid,),
        createCompanionCallback: ({required String key,Value<String?> value = const Value.absent(),Value<int> rowid = const Value.absent(),})=> SettingsCompanion.insert(key: key,value: value,rowid: rowid,),
        withReferenceMapper: (p0) => p0
              .map(
                  (e) =>
                     (e.readTable(table), BaseReferences(db, table, e))
                  )
              .toList(),
        prefetchHooksCallback: null,
        ));
        }
    typedef $$SettingsTableProcessedTableManager = ProcessedTableManager    <_$AppDatabase,
    $SettingsTable,
    Setting,
    $$SettingsTableFilterComposer,
    $$SettingsTableOrderingComposer,
    $$SettingsTableAnnotationComposer,
    $$SettingsTableCreateCompanionBuilder,
    $$SettingsTableUpdateCompanionBuilder,
    (Setting,BaseReferences<_$AppDatabase,$SettingsTable,Setting>),
    Setting,
    PrefetchHooks Function()
    >;class $AppDatabaseManager {
final _$AppDatabase _db;
$AppDatabaseManager(this._db);
$$NotesTableTableManager get notes => $$NotesTableTableManager(_db, _db.notes);
$$TodosTableTableManager get todos => $$TodosTableTableManager(_db, _db.todos);
$$PomodoroSessionsTableTableManager get pomodoroSessions => $$PomodoroSessionsTableTableManager(_db, _db.pomodoroSessions);
$$SettingsTableTableManager get settings => $$SettingsTableTableManager(_db, _db.settings);
}
