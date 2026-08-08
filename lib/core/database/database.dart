import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:local_logs/core/database/tables/log_table.dart';

part 'database.g.dart';

@DriftDatabase(tables: [LogsTbl])
class AppDatabase extends _$AppDatabase {
  /// {@macro database}
  AppDatabase(super.e);

  /// {@macro database}
  AppDatabase.defaults({required String name})
    : super(
        driftDatabase(
          name: name,
          native: const DriftNativeOptions(shareAcrossIsolates: true),
          // https://drift.simonbinder.eu/web/#prerequisites
          web: DriftWebOptions(
            sqlite3Wasm: Uri.parse('sqlite3.wasm'),
            driftWorker: Uri.parse('drift_worker.js'),
          ),
        ),
      );

  @override
  int get schemaVersion => 1;
}
