import 'package:flutter/foundation.dart';
import 'package:l/l.dart';

@immutable
class Log {
  const Log({
    required this.id,
    required this.time,
    required this.logLevel,
    required this.message,
    this.stack,
  });

  final int id;
  final int time;
  final LogLevel logLevel;
  final String message;
  final String? stack;

  Log copyWith({
    int? id,
    int? time,
    LogLevel? logLevel,
    String? message,
    ValueGetter<String?>? stack,
  }) {
    return Log(
      id: id ?? this.id,
      time: time ?? this.time,
      logLevel: logLevel ?? this.logLevel,
      message: message ?? this.message,
      stack: stack != null ? stack() : this.stack,
    );
  }

  @override
  String toString() {
    return 'Log(id: $id, time: $time, logLevel: $logLevel, message: $message, stack: $stack)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Log &&
        other.id == id &&
        other.time == time &&
        other.logLevel == logLevel &&
        other.message == message &&
        other.stack == stack;
  }

  @override
  int get hashCode {
    return id.hashCode ^ time.hashCode ^ logLevel.hashCode ^ message.hashCode ^ stack.hashCode;
  }
}
