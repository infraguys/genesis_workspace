import 'log_file_writer_base.dart';
import 'log_file_writer_stub.dart'
    if (dart.library.io) 'log_file_writer_io.dart';

export 'log_file_writer_base.dart';

LogFileWriter createLogFileWriter() => buildLogFileWriter();
