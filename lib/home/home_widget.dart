import 'package:flutter/material.dart';

/// {@template home_widget}
/// HomeWidget widget.
/// {@endtemplate}
class HomeWidget extends StatefulWidget {
  /// {@macro home_widget}
  const HomeWidget({
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<HomeWidget> createState() => _HomeWidgetState();
}

/// State for widget HomeWidget.
class _HomeWidgetState extends State<HomeWidget> {
  /* #region Lifecycle */
  @override
  void initState() {
    super.initState();
    // Initial state initialization
  }

  @override
  void dispose() {
    // Permanent removal of a tree stent
    super.dispose();
  }
  /* #endregion */

  @override
  Widget build(BuildContext context) => Scaffold(body: Center(child: Text('Home')));
}
