import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'log_file_writer_base.dart';

class _IoLogFileWriter implements LogFileWriter {
  File? _file;

  @override
  String? get filePath => _file?.path;

  @override
  Future<void> init() async {
    final directory = await getApplicationSupportDirectory();
    final filePath = p.join(directory.path, 'workspace_logs');
    final file = File(filePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
    _file = file;
  }

  @override
  Future<void> append(String line) async {
    final file = _file;
    if (file == null) return;
    await file.writeAsString('$line\n', mode: FileMode.append, flush: true);
  }
}

LogFileWriter buildLogFileWriter() => _IoLogFileWriter();
