import 'log_file_writer_base.dart';

LogFileWriter buildLogFileWriter() => const _StubLogFileWriter();

class _StubLogFileWriter implements LogFileWriter {
  const _StubLogFileWriter();

  @override
  String? get filePath => null;

  @override
  Future<void> append(String line) async {}

  @override
  Future<void> init() async {}
}
