import 'dart:async';
import 'dart:convert';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/features/logs/data/log_file_writer.dart';
import 'package:injectable/injectable.dart';
import 'package:talker_dio_logger/dio_logs.dart';
import 'package:talker_flutter/talker_flutter.dart';

part 'logs_state.dart';

@singleton
class LogsCubit extends Cubit<LogsState> {
  final LogFileWriter _logFileWriter = createLogFileWriter();
  final Talker _talker;
  StreamSubscription<TalkerData>? _logsSubscription;
  late final Future<void> _initFuture;

  LogsCubit(this._talker) : super(LogsInitial()) {
    _initFuture = _init();
  }

  Future<void> _init() async {
    try {
      await _logFileWriter.init();
    } catch (_) {
      // Swallow errors to keep the stream subscription alive even if file IO fails.
    }
    _logsSubscription = _talker.stream.listen(_handleLog);
  }

  Future<void> _handleLog(TalkerData data) async {
    final formattedLog = _formatLog(data);
    if (formattedLog == null) return;
    try {
      await _logFileWriter.append(formattedLog);
    } catch (_) {
      // Ignore IO errors to avoid interrupting the logging stream.
    }
  }

  String? _formatLog(TalkerData data) {
    final logType = _resolveLogType(data);
    if (logType == null) return null;

    final time = data.displayTime();
    final description = _normalizeDescription(data);
    if (description.isEmpty) return null;
    final extra = _extraDetails(data);

    final buffer = StringBuffer()..write('$logType | $time | $description');

    if (extra != null && extra.isNotEmpty) {
      buffer
        ..write('\n')
        ..write(extra);
    }

    buffer.write('\n-------------------------------------------------------------');
    return buffer.toString();
  }

  String? _resolveLogType(TalkerData data) {
    switch (data.key) {
      case TalkerKey.httpRequest:
      case TalkerKey.httpResponse:
      case TalkerKey.httpError:
      case TalkerKey.route:
        return data.key;
      default:
        return null;
    }
  }

  String _normalizeDescription(TalkerData data) {
    final raw = data.message ?? data.generateTextMessage();
    final normalized = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    return normalized;
  }

  String? _extraDetails(TalkerData data) {
    if (data is DioResponseLog) {
      final body = data.response.data;
      final bodyString = _stringifyBody(body);
      if (bodyString == null || bodyString.isEmpty) return null;
      return 'response: $bodyString';
    }
    return null;
  }

  String? _stringifyBody(dynamic body) {
    if (body == null) return null;
    try {
      if (body is String) return body;
      return const JsonEncoder.withIndent('  ').convert(body);
    } catch (_) {
      return body.toString();
    }
  }

  Future<String?> getLogFilePath() async {
    await _initFuture;
    return _logFileWriter.filePath;
  }

  @override
  Future<void> close() async {
    await _logsSubscription?.cancel();
    await super.close();
  }
}
