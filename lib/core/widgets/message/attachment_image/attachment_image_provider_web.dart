import 'dart:typed_data';

import 'package:flutter/widgets.dart';

ImageProvider? createAttachmentImageProvider({Uint8List? bytes, String? path}) {
  if (bytes != null && bytes.isNotEmpty) {
    return MemoryImage(bytes);
  }
  if (path != null && path.isNotEmpty) {
    return NetworkImage(path);
  }
  return null;
}
