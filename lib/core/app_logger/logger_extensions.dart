import 'package:logger/logger.dart';

extension LogLevelEx on Level {
  static Level fromValue(final int value) => switch (value) {
    999 => Level.verbose,
    1000 => Level.trace,
    2000 => Level.debug,
    3000 => Level.info,
    4000 => Level.warning,
    5000 => Level.error,
    5999 => Level.wtf,
    6000 => Level.fatal,
    9999 => Level.nothing,
    _ => Level.debug,
  };
}
