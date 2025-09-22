export 'platform_info_stub.dart'
    if (dart.library.html) 'platform_info_web.dart'
    if (dart.library.io) 'platform_info_io.dart';
