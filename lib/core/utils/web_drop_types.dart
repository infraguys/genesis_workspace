import 'package:flutter/widgets.dart';

class DroppedItem {
  final String name;
  final int size;
  final String? mime;
  final List<int> bytes;

  const DroppedItem({
    required this.name,
    required this.size,
    required this.bytes,
    this.mime,
  });
}

typedef RemoveDropHandlers = void Function();
