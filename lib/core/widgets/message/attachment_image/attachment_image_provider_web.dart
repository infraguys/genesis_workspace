import 'package:flutter/widgets.dart';

ImageProvider? createAttachmentImageProvider(String path) {
  if (path.isEmpty) return null;
  return NetworkImage(path);
}
