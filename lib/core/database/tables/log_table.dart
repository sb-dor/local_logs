import 'package:drift/drift.dart';

class LogsTbl extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get time => integer().withDefault(currentDateAndTime.unixepoch)();
  IntColumn get level => integer()();
  TextColumn get message => text()();
  TextColumn get stack => text().nullable()();

  @override
  String? get tableName => 'logs';
}
