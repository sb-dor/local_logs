import 'package:local_logs/core/app_logger/app_logger.dart';
import 'package:local_logs/core/database/database.dart';

class Dependencies {
  Dependencies();

  late final AppDatabase appDatabase;

  late final AppLogger appLogger;
}
