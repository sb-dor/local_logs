import 'package:control/control.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:l/l.dart';
import 'package:local_logs/core/date_utill.dart';
import 'package:local_logs/logs/controller/logs_controller.dart';
import 'package:local_logs/logs/models/log.dart';
import 'package:local_logs/logs/widgets/logs_scope.dart';

/// {@template logs_screen}
/// LogsScreen widget.
/// {@endtemplate}
class LogsScreen extends StatefulWidget {
  /// {@macro logs_screen}
  const LogsScreen({
    super.key, // ignore: unused_element_parameter
  });

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

/// State for widget LogsScreen.
class _LogsScreenState extends State<LogsScreen> {
  late final _logsController = LogsScope.of(context).logsController;
  late final _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Padding(
        padding: const .only(bottom: 8),
        child: RefreshIndicator.adaptive(
          onRefresh: () async {
            _logsController.load();
          },
          child: CustomScrollView(
            slivers: <Widget>[
              SliverAppBar(
                title: Text('Logs'),
                /* actions: <Widget>[
                    IconButton(icon: const Icon(Icons.delete), onPressed: () => buffer.clear()),
                    const SizedBox(width: 16),
                  ], */
                floating: true,
                pinned: MediaQuery.of(context).size.height > 600,
                actions: [
                  IconButton(
                    // where does the 'throw Exception()' goes to ?
                    // if function is 'async' it goes to runZoneGuiared
                    // if function is 'sync' it goes to flutterError

                    // but the '_logsController.throwError()' will be caught by its own controller_observer
                    onPressed: () {
                      _logsController.throwError();

                      // throw Exception();
                    },
                    icon: Icon(Icons.error, color: Colors.red),
                  ),
                ],
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(72),
                  child: Padding(
                    padding: const .symmetric(horizontal: 16, vertical: 8),
                    child: Center(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          hintText: 'Search',
                          prefixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              StateConsumer<LogsController, LogsControllerState>(
                controller: _logsController,
                builder: (context, state, child) => switch (state) {
                  LogsControllerState$Processing() => SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator.adaptive()),
                  ),
                  LogsControllerState$Failed(:final error) => SliverFillRemaining(
                    child: Center(child: Text('Something went wrong: $error')),
                  ),
                  LogsControllerState$Succeeded(:final logs) =>
                    logs.isEmpty
                        ? SliverFillRemaining(child: Center(child: Text('No logs found')))
                        : SliverPadding(
                            padding: const .symmetric(horizontal: 24, vertical: 8),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) =>
                                    _LogTile(logs[index], key: ObjectKey(logs[index])),
                                childCount: logs.length,
                              ),
                            ),
                          ),
                },
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// {@template logs_screen}
/// _LogTile widgets.
/// {@endtemplate}
class _LogTile extends StatelessWidget {
  /// {@macro logs_screen}
  const _LogTile(this.log, {super.key});

  final Log log;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ListTile(
        title: Text(log.message.toString()),
        subtitle: Text(DateTime.fromMillisecondsSinceEpoch(log.time).format()),
        leading: _LogIcon(log.logLevel),
        dense: true,
        trailing: IconButton(
          icon: const Icon(Icons.copy),
          onPressed: () => Clipboard.setData(
            ClipboardData(text: log.stack != null ? '${log.message}\n${log.stack}' : log.message),
          ),
        ),
      ),
      const Divider(height: 1),
    ],
  );
}

class _LogIcon extends StatelessWidget {
  const _LogIcon(this.level);

  final LogLevel level;

  @override
  Widget build(BuildContext context) => level.when<Widget>(
    debug: () => const Icon(Icons.bug_report, color: Colors.indigo),
    info: () => const Icon(Icons.info, color: Colors.blue),
    warning: () => const Icon(Icons.warning, color: Colors.orange),
    error: () => const Icon(Icons.error, color: Colors.red),
    shout: () => const Icon(Icons.campaign, color: Colors.red),
    v: () => const Icon(Icons.looks_one, color: Colors.grey),
    vv: () => const Icon(Icons.looks_two, color: Colors.grey),
    vvv: () => const Icon(Icons.looks_3, color: Colors.grey),
    vvvv: () => const Icon(Icons.looks_4, color: Colors.grey),
    vvvvv: () => const Icon(Icons.looks_5, color: Colors.grey),
    vvvvvv: () => const Icon(Icons.looks_6, color: Colors.grey),
  );
}
