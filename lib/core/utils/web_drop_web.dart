import 'dart:async';
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

import 'web_drop_types.dart';

RemoveDropHandlers attachWebDropHandlersForKey({
  required GlobalKey targetKey,
  required void Function(bool isOver) onIsOverChange,
  required void Function(List<DroppedItem> files) onDrop,
}) {
  bool isInside = false;

  void handleDragOver(html.Event e) {
    if (e is html.MouseEvent) {
      if (_isPointInsideKey(targetKey, e.client.x.toDouble(), e.client.y.toDouble())) {
        e.preventDefault();
        if (!isInside) {
          isInside = true;
          onIsOverChange(true);
        }
      } else {
        if (isInside) {
          isInside = false;
          onIsOverChange(false);
        }
      }
    }
  }

  void handleDragLeave(html.Event e) {
    if (isInside) {
      isInside = false;
      onIsOverChange(false);
    }
  }

  Future<void> handleDrop(html.Event e) async {
    if (e is! html.MouseEvent) return;
    final dropEvent = e as dynamic; // to access dataTransfer consistently
    if (!(_isPointInsideKey(targetKey, e.client.x.toDouble(), e.client.y.toDouble()))) {
      if (isInside) {
        isInside = false;
        onIsOverChange(false);
      }
      return;
    }
    e.preventDefault();
    e.stopPropagation();
    if (isInside) {
      isInside = false;
      onIsOverChange(false);
    }
    final html.DataTransfer? dt = (dropEvent.dataTransfer as html.DataTransfer?);
    if (dt == null) return;
    final List<html.File> files = dt.files?.toList() ?? const <html.File>[];
    if (files.isEmpty) return;

    final List<DroppedItem> result = [];
    for (final f in files) {
      final bytes = await _readFileBytes(f);
      result.add(DroppedItem(
        name: f.name,
        size: f.size,
        mime: f.type,
        bytes: bytes,
      ));
    }
    onDrop(result);
  }

  html.EventListener _dragOverListener = (e) {};
  html.EventListener _dropListener = (e) {};
  html.EventListener _dragLeaveListener = (e) {};

  _dragOverListener = handleDragOver;
  _dropListener = (e) {
    // ensure async
    unawaited(handleDrop(e));
  };
  _dragLeaveListener = handleDragLeave;

  html.window.addEventListener('dragover', _dragOverListener);
  html.window.addEventListener('drop', _dropListener);
  html.window.addEventListener('dragleave', _dragLeaveListener);

  return () {
    html.window.removeEventListener('dragover', _dragOverListener);
    html.window.removeEventListener('drop', _dropListener);
    html.window.removeEventListener('dragleave', _dragLeaveListener);
  };
}

bool _isPointInsideKey(GlobalKey key, double clientX, double clientY) {
  final ctx = key.currentContext;
  if (ctx == null) return false;
  final box = ctx.findRenderObject() as RenderBox?;
  if (box == null || !box.attached) return false;
  final topLeft = box.localToGlobal(Offset.zero);
  final size = box.size;
  final rect = Rect.fromLTWH(topLeft.dx, topLeft.dy, size.width, size.height);
  return rect.contains(Offset(clientX, clientY));
}

Future<List<int>> _readFileBytes(html.File file) async {
  final completer = Completer<List<int>>();
  final reader = html.FileReader();
  reader.onLoadEnd.listen((_) {
    final result = reader.result;
    if (result is ByteBuffer) {
      completer.complete(result.asUint8List());
    } else if (result is Uint8List) {
      completer.complete(result);
    } else {
      completer.complete(const <int>[]);
    }
  });
  reader.onError.listen((_) => completer.complete(const <int>[]));
  reader.readAsArrayBuffer(file);
  return completer.future;
}
