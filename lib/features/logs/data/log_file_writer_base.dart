abstract class LogFileWriter {
  String? get filePath;

  Future<void> init();

  Future<void> append(String line);
}
