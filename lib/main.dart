import 'dart:async';
import 'package:control/control.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:l/l.dart';
import 'package:local_logs/app.dart';
import 'package:local_logs/core/controller_observer/controller_observer.dart';
import 'package:local_logs/core/database/database.dart';
import 'package:local_logs/dependencies.dart';
import 'package:rxdart/rxdart.dart';

void main() async => runZonedGuarded(
  () async {
    final binding = WidgetsFlutterBinding.ensureInitialized()..deferFirstFrame();
    await _catchExceptions();

    final dependencies = Dependencies();
    final initialization = await _initializeDependencies();
    for (final step in initialization.values) {
      await step.call(dependencies);
    }

    binding.allowFirstFrame();
    runApp(App(dependencies: dependencies));
  },
  (error, stackTrace) {
    // async errors will come here
    l.e(error, stackTrace);
  },
);

typedef DependenciesFunctionInitializer = Future<void> Function(Dependencies dependencies);

Future<Map<String, DependenciesFunctionInitializer>> _initializeDependencies() async {
  return {
    'init controller observer': (dependencies) async => Controller.observer = ControllerObserver(),
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
        l.bufferTime(Duration(seconds: 1)).where((logs) => logs.isNotEmpty).listen((logs) async {
          await dependencies.appDatabase.batch(
            (batch) => batch.insertAll(
              dependencies.appDatabase.logsTbl,
              logs.map(
                (log) => LogsTblCompanion(
                  level: Value(log.level.level),
                  message: Value(log.message.toString()),
                  time: Value<int>(log.timestamp.millisecondsSinceEpoch ~/ 1000),
                  stack: Value<String?>(switch (log) {
                    LogMessageError l => l.stackTrace.toString(),
                    _ => null,
                  }),
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
Future<void> _catchExceptions() async {
  try {
    PlatformDispatcher.instance.onError = (error, stackTrace) {
      l.e(error, stackTrace, {'hint': 'ROOT ERROR\r\n${Error.safeToString(error)}'});
      return true;
    };

    final sourceFlutterError = FlutterError.onError;
    FlutterError.onError = (final details) {
      l.e(details.exception, details.stack ?? StackTrace.current, {
        'hint': 'FLUTTER ERROR\r\n$details',
      });
      // FlutterError.presentError(details);
      sourceFlutterError?.call(details);
    };
  } on Object catch (error, stackTrace) {
    l.e(error, stackTrace);
  }
}
