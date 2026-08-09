import 'package:control/control.dart';
import 'package:local_logs/core/app_logger/app_logger.dart';
import 'package:logger/logger.dart';

/// Observer for [Controller], react to changes in any controller.
final class ControllerObserver implements IControllerObserver {
  const ControllerObserver(this._appLogger);

  final AppLogger _appLogger;

  @override
  void onCreate(Controller controller) {
    _appLogger.log(Level.info, 'Controller | ${controller.name}.new');
  }

  @override
  void onDispose(Controller controller) {
    _appLogger.log(Level.info, 'Controller | ${controller.name}.dispose');
  }

  @override
  void onHandler(HandlerContext context) {
    final stopwatch = Stopwatch()..start();
    _appLogger.log(
      Level.info,
      'Controller | ${context.controller.name}.${context.name} | ${context.meta}',
    );
    context.done.whenComplete(() {
      stopwatch.stop();
      _appLogger.log(
        Level.info,
        'Controller | ${context.controller.name}.${context.name} | duration: ${stopwatch.elapsed} | ${context.meta}',
      );
    });
  }

  @override
  void onStateChanged<S extends Object>(StateController<S> controller, S prevState, S nextState) {
    final context = Controller.context;
    if (context == null) {
      // State change occurred outside of the handler
      _appLogger.log(Level.info, 'StateController | ${controller.name} | $prevState -> $nextState');
    } else {
      // State change occurred inside the handler
      _appLogger.log(
        Level.info,
        'StateController | ${controller.name}.${context.name} | $prevState -> $nextState | ${context.meta}',
      );
    }
  }

  /// error should not be propagated from this [observer] to the outside
  /// So the [ErrorUtil] logs the error and sends to the Crashlytics/Sentry directly from this [observer]
  @override
  void onError(Controller controller, Object error, StackTrace stackTrace) {
    final context = Controller.context;
    if (context == null) {
      // Error occurred outside of the handler
      _appLogger.log(Level.error, 'Controller | ${controller.name}', error, stackTrace);
    } else {
      // Error occurred inside the handler
      _appLogger.log(
        Level.error,
        'Controller | ${controller.name}.${context.name}',
        error,
        stackTrace,
      );
    }
    _appLogger.log(Level.info, "Controller observer error", error, stackTrace);
  }
}

// Example of any event
// Future<void> event({
//   Map<String, Object?>? meta,
//   void Function(HandlerContext context)? out,
// }) =>
//     handle(
//       () async {
//         final stopwatch = Stopwatch()..start();
//         try {
//           setState(false);
//           await Future<void>.delayed(Duration.zero);
//           out?.call(Controller.context!);
//           setState(true);
//           Controller.context?.meta['duration'] = stopwatch.elapsed;
//         } finally {
//           stopwatch.stop();
//         }
//       },
//       name: 'event',
//       meta: {
//         ...?meta,
//         'started_at': DateTime.now(),
//       },
//     );
