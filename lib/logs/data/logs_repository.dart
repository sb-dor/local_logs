import 'package:drift/drift.dart';
import 'package:local_logs/core/database/database.dart';
import 'package:local_logs/logs/models/log.dart';
import 'package:local_logs/core/app_logger/logger_extensions.dart' as logger_ex;

abstract interface class ILogsRepository {
  /// Returns the stored logs, newest first.
  ///
  /// When [search] is a non-blank string, only logs whose message or stack
  /// trace contain it (case-insensitive) are returned.
  Future<List<Log>> logs({String? search});
}

final class LogsRepositoryImpl implements ILogsRepository {
  LogsRepositoryImpl({required this._appDatabase});

  /// Escape character for the `LIKE` patterns built by [_likePattern].
  static const String _likeEscape = r'\';

  final AppDatabase _appDatabase;

  @override
  Future<List<Log>> logs({String? search}) async {
    final selectable = _appDatabase.select(_appDatabase.logsTbl)
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.time, mode: OrderingMode.desc)]);

    final pattern = _likePattern(search);
    if (pattern != null) {
      selectable.where(
        (tbl) =>
            tbl.message.like(pattern, escapeChar: _likeEscape) |
            tbl.stack.like(pattern, escapeChar: _likeEscape),
      );
    }

    final localLogs = await selectable.get();
    return localLogs
        .map(
          (log) => Log(
            id: log.id,
            time: log.time,
            logLevel: logger_ex.LogLevelEx.fromValue(log.level),
            message: log.message,
            stack: log.stack,
          ),
        )
        .toList();
  }

  /// Builds a `%contains%` pattern, escaping the `LIKE` wildcards so that a
  /// query such as `100%` is matched literally instead of as a wildcard.
  ///
  /// Returns `null` when there is nothing to search for.
  static String? _likePattern(String? search) {
    final trimmed = search?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    final escaped = trimmed
        .replaceAll(_likeEscape, r'\\')
        .replaceAll('%', r'\%')
        .replaceAll('_', r'\_');
    return '%$escaped%';
  }
}
