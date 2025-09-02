import 'package:dart_mappable/dart_mappable.dart';

part 'log_data_vo.mapper.dart';

@MappableClass()
class LogDataVo with LogDataVoMappable {
  String? message;
  String? logLevel;
  String? exception;
  String? error;
  String? stackTrace;
  String? title;
  String? time;

  LogDataVo({
    this.message,
    this.logLevel,
    this.exception,
    this.error,
    this.stackTrace,
    this.title,
    this.time,
  });
}
