import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';
import 'package:path/path.dart' as path;
import 'package:super_clipboard/super_clipboard.dart';

@lazySingleton
class PasteCaptureService {
  final SystemClipboard? clipboard = SystemClipboard.instance;

  Future<dynamic> captureNow({bool? isWeb, ClipboardReader? webReader}) async {
    late final ClipboardReader reader;
    if (isWeb == true) {
      reader = webReader!;
    } else {
      if (clipboard == null) return null;
      reader = await clipboard!.read();
    }

    final PlatformFile? pastedImage = await _tryReadImageAsPlatformFile(reader);
    if (pastedImage != null) return pastedImage;

    // 2) PDF (пример для не-изображений)
    final PlatformFile? pastedPdf = await _tryReadSingleFile(
      reader,
      Formats.pdf,
      defaultName: 'pasted_document.pdf',
    );
    if (pastedPdf != null) return pastedPdf;

    if (reader.canProvide(Formats.plainText)) {
      final String text = await reader.readValue(Formats.plainText) ?? '';
      return text;
    }

    return null;
  }

  Future<PlatformFile?> _tryReadImageAsPlatformFile(ClipboardReader reader) async {
    final imageFormats = [Formats.png, Formats.jpeg, Formats.gif, Formats.webp];

    for (final format in imageFormats) {
      if (!reader.canProvide(format)) continue;
      final Completer<PlatformFile> completer = Completer<PlatformFile>();
      reader.getFile(format, (file) async {
        final Uint8List bytes = await file.readAll();
        final String suggestedName = (file.fileName?.trim().isNotEmpty ?? false)
            ? file.fileName!.trim()
            : (await reader.getSuggestedName() ?? 'pasted_image');
        final String nameWithExt = _ensureImageExtension(suggestedName, format);
        completer.complete(PlatformFile(name: nameWithExt, size: bytes.length, bytes: bytes));
      });
      return completer.future;
    }
    return null;
  }

  Future<PlatformFile?> _tryReadSingleFile(
    ClipboardReader reader,
    format, {
    required String defaultName,
  }) async {
    if (!reader.canProvide(format)) return null;

    final Completer<PlatformFile> completer = Completer<PlatformFile>();

    reader.getFile(format, (dataFile) async {
      final String filename = (dataFile.fileName?.trim().isNotEmpty ?? false)
          ? dataFile.fileName!.trim()
          : (await reader.getSuggestedName() ?? defaultName);

      final Stream<Uint8List> stream = dataFile.getStream();

      if (kIsWeb) {
        final BytesBuilder bytesBuilder = BytesBuilder(copy: false);
        await for (final Uint8List chunk in stream) {
          bytesBuilder.add(chunk);
        }
        final Uint8List bytes = bytesBuilder.takeBytes();
        completer.complete(PlatformFile(name: filename, size: bytes.length, bytes: bytes));
      } else {
        final _SpoolResult spool = await _spoolStreamToTempFile(stream, suggestedName: filename);
        completer.complete(
          PlatformFile(name: spool.fileName, size: spool.sizeBytes, path: spool.path),
        );
      }
    });

    return completer.future;
  }

  Future<_SpoolResult> _spoolStreamToTempFile(
    Stream<Uint8List> stream, {
    required String suggestedName,
  }) async {
    final Directory tempDir = await Directory.systemTemp.createTemp('pasted_');
    final String safeName = suggestedName.isEmpty ? 'pasted_file' : suggestedName;
    final String fullPath = path.join(tempDir.path, safeName);

    final IOSink sink = File(fullPath).openWrite();
    int total = 0;
    await for (final Uint8List chunk in stream) {
      sink.add(chunk);
      total += chunk.length;
    }
    await sink.flush();
    await sink.close();

    return _SpoolResult(path: fullPath, fileName: safeName, sizeBytes: total);
  }

  String _ensureImageExtension(String name, format) {
    final String lower = name.toLowerCase();
    if (format == Formats.png && !lower.endsWith('.png')) return '$name.png';
    if (format == Formats.jpeg && !(lower.endsWith('.jpg') || lower.endsWith('.jpeg')))
      return '$name.jpg';
    if (format == Formats.gif && !lower.endsWith('.gif')) return '$name.gif';
    if (format == Formats.webp && !lower.endsWith('.webp')) return '$name.webp';
    return name;
  }
}

class _SpoolResult {
  final String path;
  final String fileName;
  final int sizeBytes;
  _SpoolResult({required this.path, required this.fileName, required this.sizeBytes});
}
