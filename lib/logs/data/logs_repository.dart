import 'package:drift/drift.dart';
import 'package:l/l.dart';
import 'package:local_logs/core/database/database.dart';
import 'package:local_logs/logs/models/log.dart';

abstract interface class ILogsRepository {
  Future<List<Log>> logs();
}

final class LogsRepositoryImpl implements ILogsRepository {
  LogsRepositoryImpl({required this._appDatabase});

  final AppDatabase _appDatabase;

  @override
  Future<List<Log>> logs() async {
    final localLogs = await (_appDatabase.select(
      _appDatabase.logsTbl,
    )..orderBy([(tbl) => OrderingTerm(expression: tbl.time, mode: OrderingMode.desc)])).get();
    return localLogs
        .map(
          (log) => Log(
            id: log.id,
            time: log.time,
            logLevel: LogLevel.fromValue(log.level),
            message: log.message,
            stack: log.stack,
          ),
        )
        .toList();
  }
}
