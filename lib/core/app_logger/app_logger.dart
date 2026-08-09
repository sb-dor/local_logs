import 'dart:async';
import 'package:logger/logger.dart';

class AppLogger extends Stream<LogEvent> {
  AppLogger({required this._logger});

  final Logger _logger;

  bool get hasListener => _controller.hasListener;

  final StreamController<LogEvent> _controller = StreamController<LogEvent>.broadcast();

  void log(Level level, String message, [Object? error, StackTrace? stackTrace]) {
    _logger.log(level, message, error: error, stackTrace: stackTrace);
    if (!hasListener) return;
    _controller.add(LogEvent(level, message, error: error, stackTrace: stackTrace));
  }

  @override
  StreamSubscription<LogEvent> listen(
    void Function(LogEvent event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => _controller.stream.listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError ?? false,
  );
}
