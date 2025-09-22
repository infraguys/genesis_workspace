import 'dart:async';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:super_clipboard/super_clipboard.dart';

@lazySingleton
class PasteCaptureService {
  final SystemClipboard? clipboard = SystemClipboard.instance;

  Future<dynamic> captureNow() async {
    // --- ВЕБ: лучше слушать paste-событие и брать reader оттуда ---
    // см. README: ClipboardEvents.instance.registerPasteEventListener(...) (Web) :contentReference[oaicite:1]{index=1}

    if (clipboard == null) return null;
    final ClipboardReader reader = await clipboard!.read();

    // 1) Изображения — проверяем ПЕРВЫМИ (иначе могли бы вернуться текст/HTML раньше).
    final PlatformFile? pastedImage = await _tryReadImageAsPlatformFile(reader);
    if (pastedImage != null) return pastedImage;

    // 2) PDF (пример для не-изображений)
    final PlatformFile? pastedPdf = await _tryReadSingleFile(
      reader,
      Formats.pdf,
      defaultName: 'pasted_document.pdf',
    );
    if (pastedPdf != null) return pastedPdf;

    final PlatformFile? pastedApk = await _tryReadSingleFile(
      reader,
      Formats.apk,
      defaultName: 'pasted_apk.apk',
    );
    if (pastedApk != null) return pastedApk;

    // 3) HTML → далее plain text (если нужно)
    if (reader.canProvide(Formats.htmlText)) {
      final String html = await reader.readValue(Formats.htmlText) ?? '';
      if (html.trim().isNotEmpty) return html;
    }
    if (reader.canProvide(Formats.plainText)) {
      final String text = await reader.readValue(Formats.plainText) ?? '';
      return text; // строка
    }

    // 4) Ничего подходящего
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
    reader.getFile(format, (file) async {
      final Uint8List bytes = await file.readAll();
      final String filename = (file.fileName?.trim().isNotEmpty ?? false)
          ? file.fileName!.trim()
          : (await reader.getSuggestedName() ?? defaultName);
      completer.complete(PlatformFile(name: filename, size: bytes.length, bytes: bytes));
    });
    return completer.future;
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
