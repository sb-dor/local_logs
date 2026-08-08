import 'package:control/control.dart';
import 'package:local_logs/logs/data/logs_repository.dart';
import 'package:local_logs/logs/models/log.dart';

/// Entity placeholder
typedef LogsControllerStateEntity = Object;

/// {@template logs_controller_state}
/// LogsControllerState.
/// {@endtemplate}
sealed class LogsControllerState {
  /// {@macro logs_controller_state}
  const LogsControllerState();

  /// Processing
  /// {@macro logs_controller_state}
  const factory LogsControllerState.processing() = LogsControllerState$Processing;

  /// Failed
  /// {@macro logs_controller_state}
  const factory LogsControllerState.failed({final Object? error}) = LogsControllerState$Failed;

  /// Succeeded
  /// {@macro logs_controller_state}
  const factory LogsControllerState.succeeded({required List<Log> logs}) =
      LogsControllerState$Succeeded;
}

/// Processing
final class LogsControllerState$Processing extends LogsControllerState {
  const LogsControllerState$Processing();
}

/// Failed
final class LogsControllerState$Failed extends LogsControllerState {
  const LogsControllerState$Failed({this.error});

  final Object? error;
}

/// Succeeded
final class LogsControllerState$Succeeded extends LogsControllerState {
  const LogsControllerState$Succeeded({required this.logs});

  final List<Log> logs;
}

class LogsController extends StateController<LogsControllerState> with SequentialControllerHandler {
  LogsController({
    required this._iLogsRepository,
    super.initialState = const LogsControllerState.processing(),
  });

  final ILogsRepository _iLogsRepository;

  /// Loads the logs, optionally filtered by [search].
  Future<void> load({String? search}) => handle(() async {
    setState(const LogsControllerState.processing());

    final logs = await _iLogsRepository.logs(search: search);

    setState(LogsControllerState.succeeded(logs: logs));
  }, error: (error, stackTrace) async => setState(LogsControllerState.failed(error: error)));

  Future<void> throwError() => handle(() async => throw Exception());
}
