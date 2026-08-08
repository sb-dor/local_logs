import 'package:flutter/material.dart';
import 'package:local_logs/dependencies_scope.dart';
import 'package:local_logs/logs/controller/logs_controller.dart';
import 'package:local_logs/logs/data/logs_repository.dart';
import 'package:local_logs/logs/widgets/logs_screen.dart';

/// {@template logs_scope}
/// _LogsScope widget.
/// {@endtemplate}
class _LogsScope extends InheritedWidget {
  /// {@macro logs_scope}
  const _LogsScope({
    required this.state,
    required super.child,
    super.key, // ignore: unused_element_parameter
  });

  final LogsScopeState state;

  @override
  bool updateShouldNotify(covariant _LogsScope oldWidget) => false;
}

/// {@template logs_scope}
/// LogsScope widget.
/// {@endtemplate}
class LogsScope extends StatefulWidget {
  /// {@macro logs_scope}
  const LogsScope({
    super.key, // ignore: unused_element_parameter
  });

  static LogsScopeState of(BuildContext context) {
    final widget = context.getElementForInheritedWidgetOfExactType<_LogsScope>()?.widget;
    assert(widget != null, 'No LogsScope was found in element tree');
    return (widget as _LogsScope).state;
  }

  @override
  State<LogsScope> createState() => LogsScopeState();
}

/// State for widget LogsScope.
class LogsScopeState extends State<LogsScope> {
  late final LogsController logsController;

  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
    final dependencies = DependenciesScope.of(context);
    logsController = LogsController(
      iLogsRepository: LogsRepositoryImpl(appDatabase: dependencies.appDatabase),
    );
    Future.delayed(const Duration(seconds: 2), () => logsController.load());
  }

  @override
  void dispose() {
    // Permanent removal of a tree stent
    logsController.dispose();
    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) => _LogsScope(state: this, child: LogsScreen());
}
