import 'package:genesis_workspace/data/messages/dto/upload_file_dto.dart';

import 'platform_chunk_reader_io.dart'
    if (dart.library.html) 'platform_chunk_reader_web.dart'
    as impl;
import 'platform_chunk_reader_stub.dart';

export 'platform_chunk_reader_io.dart' if (dart.library.html) 'platform_chunk_reader_web.dart';
export 'platform_chunk_reader_stub.dart';

PlatformChunkReader createPlatformChunkReader(UploadFileRequestDto body) =>
    impl.createPlatformChunkReader(body);
