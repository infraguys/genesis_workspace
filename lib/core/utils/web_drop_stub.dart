import 'package:flutter/widgets.dart';
import 'web_drop_types.dart';

RemoveDropHandlers? attachWebDropHandlersForKey({
  required GlobalKey targetKey,
  required void Function(bool isOver) onIsOverChange,
  required void Function(List<DroppedItem> files) onDrop,
}) {
  // No-op on non-web platforms.
  return null;
}
