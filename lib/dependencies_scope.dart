import 'package:flutter/material.dart';
import 'package:local_logs/dependencies.dart';

/// {@template app}
/// Dependencies widget.
/// {@endtemplate}
class DependenciesScope extends InheritedWidget {
  /// {@macro app}
  const DependenciesScope({
    required this.dependencies,
    required super.child,
    super.key, // ignore: unused_element_parameter
  });

  static Dependencies of(BuildContext context) {
    final widget = context.getElementForInheritedWidgetOfExactType<DependenciesScope>()?.widget;
    assert(widget != null, 'No DependenciesScope was found in element tree');
    return (widget as DependenciesScope).dependencies;
  }

  final Dependencies dependencies;

  @override
  bool updateShouldNotify(covariant DependenciesScope oldWidget) => false;
}
