import 'package:flutter/material.dart';
import 'package:local_logs/dependencies.dart';
import 'package:local_logs/dependencies_scope.dart';
import 'package:local_logs/logs/widgets/logs_scope.dart';

/// {@template app}
/// App widget.
/// {@endtemplate}
class App extends StatefulWidget {
  /// {@macro app}
  const App({
    required this.dependencies,
    super.key, // ignore: unused_element_parameter
  });

  final Dependencies dependencies;

  @override
  State<App> createState() => _AppState();
}

/// State for widget App.
class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) => DependenciesScope(
    dependencies: widget.dependencies,
    child: MaterialApp(home: LogsScope()),
  );
}
