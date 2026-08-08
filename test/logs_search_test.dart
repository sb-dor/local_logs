import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:local_logs/core/database/database.dart';
import 'package:local_logs/logs/data/logs_repository.dart';

void main() {
  late AppDatabase db;
  late ILogsRepository repository;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    repository = LogsRepositoryImpl(appDatabase: db);
    await db.batch(
      (batch) => batch.insertAll(db.logsTbl, <LogsTblCompanion>[
        LogsTblCompanion.insert(level: 3, message: 'Connection refused', time: const Value(1)),
        LogsTblCompanion.insert(level: 1, message: 'Battery at 100%', time: const Value(2)),
        LogsTblCompanion.insert(level: 1, message: 'user_id resolved', time: const Value(3)),
        LogsTblCompanion.insert(
          level: 5,
          message: 'Crash',
          time: const Value(4),
          stack: const Value('#0 refusedByPeer'),
        ),
      ]),
    );
  });

  tearDown(() => db.close());

  List<String> messages(Iterable<dynamic> logs) => logs.map((l) => l.message as String).toList();

  test('returns everything, newest first, when the query is blank', () async {
    expect(messages(await repository.logs()), <String>[
      'Crash',
      'user_id resolved',
      'Battery at 100%',
      'Connection refused',
    ]);
    expect(messages(await repository.logs(search: '   ')), hasLength(4));
  });

  test('matches the message case-insensitively', () async {
    expect(messages(await repository.logs(search: 'CONNECTION')), <String>['Connection refused']);
  });

  test('matches the stack trace too', () async {
    expect(messages(await repository.logs(search: 'refused')), <String>[
      'Crash',
      'Connection refused',
    ]);
  });

  test('treats % as a literal, not a wildcard', () async {
    expect(messages(await repository.logs(search: '100%')), <String>['Battery at 100%']);
    expect(await repository.logs(search: 'Battery%at'), isEmpty);
  });

  test('treats _ as a literal, not a single-char wildcard', () async {
    expect(messages(await repository.logs(search: 'user_id')), <String>['user_id resolved']);
    expect(await repository.logs(search: 'userxid'), isEmpty);
  });

  test('returns nothing when there is no match', () async {
    expect(await repository.logs(search: 'nothing here'), isEmpty);
  });
}
