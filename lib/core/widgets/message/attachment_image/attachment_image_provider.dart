export 'attachment_image_provider_stub.dart'
    if (dart.library.html) 'attachment_image_provider_web.dart'
    if (dart.library.io) 'attachment_image_provider_io.dart';
