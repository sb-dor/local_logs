import 'dart:async';
import 'package:control/control.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:local_logs/app.dart';
import 'package:local_logs/core/app_logger/app_logger.dart';
import 'package:local_logs/core/controller_observer/controller_observer.dart';
import 'package:local_logs/core/database/database.dart';
import 'package:local_logs/dependencies.dart';
import 'package:logger/web.dart';
import 'package:rxdart/rxdart.dart';

final class NoOpLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return false;
  }
}

void main() async {
  final logger = Logger(
    filter: kReleaseMode ? NoOpLogFilter() : DevelopmentFilter(),
    printer: PrettyPrinter(
      methodCount: 2,
      // Number of method calls to be displayed
      errorMethodCount: 8,
      // Number of method calls if stacktrace is provided
      lineLength: 120,
      // Colorful log messages
      colors: true,
      // Print an emoji for each log message
      printEmojis: true,
      // Should each log print contain a timestamp
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
    output: ConsoleOutput(),
  );

  final appLogger = AppLogger(logger: logger);

  await runZonedGuarded(
    () async {
      final binding = WidgetsFlutterBinding.ensureInitialized()..deferFirstFrame();
      await _catchExceptions(appLogger);

      final dependencies = Dependencies()..appLogger = appLogger;
      final initialization = await _initializeDependencies();
      for (final step in initialization.values) {
        await step.call(dependencies);
      }

      binding.allowFirstFrame();
      runApp(App(dependencies: dependencies));
    },
    (error, stackTrace) {
      // async errors will come here
      appLogger.log(Level.error, "RunZoneGuardedError", error, stackTrace);
    },
  );
}

typedef DependenciesFunctionInitializer = Future<void> Function(Dependencies dependencies);

Future<Map<String, DependenciesFunctionInitializer>> _initializeDependencies() async {
  return {
    'init controller observer': (dependencies) async =>
        Controller.observer = ControllerObserver(dependencies.appLogger),
    //
    'app_database': (dependencies) async =>
        dependencies.appDatabase = AppDatabase.defaults(name: 'local_logs'),
    //
    if (!kReleaseMode)
      'clear local logs table': (dependencies) async {
        await dependencies.appDatabase.delete(dependencies.appDatabase.logsTbl).go();
        await dependencies.appDatabase.customStatement(
          "DELETE FROM sqlite_sequence WHERE name='logs'",
        );
      },
    //
    if (!kReleaseMode)
      'listen to local logs': (dependencies) async {
        dependencies.appLogger
            .bufferTime(Duration(seconds: 1))
            .where((logs) => logs.isNotEmpty)
            .listen((logs) async {
              await dependencies.appDatabase.batch(
                (batch) => batch.insertAll(
                  dependencies.appDatabase.logsTbl,
                  logs.map(
                    (log) => LogsTblCompanion(
                      level: Value(log.level.value),
                      message: Value(log.message.toString()),
                      time: Value<int>(log.time.millisecondsSinceEpoch ~/ 1000),
                      stack: Value(log.stackTrace?.toString()),
                    ),
                  ),
                ),
              );
            }, cancelOnError: false);
      },
    //
  };
}

/// catches Flutter error
Future<void> _catchExceptions(final AppLogger appLogger) async {
  try {
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      appLogger.log(Level.error, "PlatformDispatcher Error", error, stackTrace);
      return true;
    };

    final sourceFlutterError = FlutterError.onError;
    FlutterError.onError = (final details) {
      appLogger.log(
        Level.error,
        "Flutter Error",
        details.exception,
        details.stack ?? StackTrace.current,
      );
      // FlutterError.presentError(details);
      sourceFlutterError?.call(details);
    };
  } on Object catch (error, stackTrace) {
    appLogger.log(Level.error, "_catchExceptions try-catch error", error, stackTrace);
  }
}
