import 'dart:async';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/utils/url_updater_stub.dart'
    if (dart.library.html) 'package:genesis_workspace/core/utils/url_updater_web.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:image_picker/image_picker.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:super_drag_and_drop/super_drag_and_drop.dart';

String? validateEmail(String? value) {
  final emailRegex = RegExp(r'^[\w.+-]+@([\w-]+\.)+[\w-]{2,}$');

  if (value == null || value.isEmpty) {
    return 'Please enter your email';
  } else if (!RegExp(emailRegex.pattern).hasMatch(value)) {
    return 'Enter a valid email address';
  }
  return null;
}

class ToListAsJsonStringConverter implements JsonConverter<List<String>, String> {
  const ToListAsJsonStringConverter();

  @override
  List<String> fromJson(String jsonStr) {
    final List<dynamic> decoded = json.decode(jsonStr);
    return decoded.map((e) => e.toString()).toList();
  }

  @override
  String toJson(List<String> object) {
    return json.encode(object);
  }
}

Color parseColor(String hexColor) {
  final buffer = StringBuffer();
  if (hexColor.length == 6 || hexColor.length == 7) buffer.write('ff');
  buffer.write(hexColor.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}

String timeAgoText(BuildContext context, DateTime lastSeen) {
  final now = DateTime.now();
  final diff = now.difference(lastSeen);

  if (diff.inMinutes < 1) {
    return context.t.timeAgo.justNow;
  } else if (diff.inHours < 1) {
    return context.t.timeAgo.minutes(n: diff.inMinutes);
  } else if (diff.inDays < 1) {
    return context.t.timeAgo.hours(n: diff.inHours);
  } else {
    return context.t.timeAgo.days(n: diff.inDays);
  }
}

bool isJustNow(DateTime lastSeen) {
  final diff = DateTime.now().difference(lastSeen);
  return diff.inMinutes < 1;
}

Size? parseDimensions(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final parts = raw.split('x');
  if (parts.length != 2) return null;
  final w = double.tryParse(parts[0]);
  final h = double.tryParse(parts[1]);
  if (w == null || h == null || w <= 0 || h <= 0) return null;
  return Size(w, h);
}

Size? extractDimensionsFromUrl(String url) {
  final regex = RegExp(r'/(\d+)x(\d+)\.(?:webp|png|jpg|jpeg)$', caseSensitive: false);
  final match = regex.firstMatch(url);
  if (match != null) {
    final width = double.tryParse(match.group(1)!);
    final height = double.tryParse(match.group(2)!);
    if (width != null && height != null) {
      return Size(width, height);
    }
  }
  return null;
}

void updateBrowserUrlPath(String path, {bool addToHistory = true}) {
  final normalizedPath = path.startsWith('/') ? path : '/$path';
  platformUpdateBrowserUrlPath(normalizedPath, addToHistory: addToHistory);
}

String generateMessageQuote(MessageEntity message) {
  final quoteText =
      '''@_**${message.senderFullName}|${message.senderId}** [писал/а]:
```quote
${message.content}
```
''';
  return quoteText;
}

String extensionOf(String fileName) {
  final int dotIndex = fileName.lastIndexOf('.');
  if (dotIndex == -1 || dotIndex == fileName.length - 1) return '';
  return fileName.substring(dotIndex + 1).toLowerCase();
}

bool isImageExtension(String extension) {
  const imageExts = AppConstants.kImageExtensions;
  return imageExts.contains(extension);
}

/// Форматирует размер файла в человекочитаемый вид.
/// [byteCount] — размер в байтах.
/// [useBinaryUnits] — false: KB/MB/GB (1000); true: KiB/MiB/GiB (1024).
/// [fractionDigits] — количество знаков после запятой.
/// [trimTrailingZeros] — убрать хвостовые нули и лишнюю точку.
String formatFileSize(
  int byteCount, {
  bool useBinaryUnits = false,
  int fractionDigits = 1,
  bool trimTrailingZeros = true,
}) {
  if (byteCount < 0) throw ArgumentError.value(byteCount, 'byteCount', 'must be >= 0');

  const List<String> decimalUnits = ['B', 'KB', 'MB', 'GB', 'TB', 'PB'];
  const List<String> binaryUnits = ['B', 'KiB', 'MiB', 'GiB', 'TiB', 'PiB'];

  final int base = useBinaryUnits ? 1024 : 1000;
  final List<String> units = useBinaryUnits ? binaryUnits : decimalUnits;

  if (byteCount < base) {
    return '$byteCount ${units.first}';
  }

  double value = byteCount.toDouble();
  int unitIndex = 0;

  while (value >= base && unitIndex < units.length - 1) {
    value /= base;
    unitIndex++;
  }

  String number = value.toStringAsFixed(fractionDigits);
  if (trimTrailingZeros && number.contains('.')) {
    number = number.replaceFirst(RegExp(r'\.?0+$'), '');
  }
  const String thinNbsp = '\u202F';
  return '$number$thinNbsp${units[unitIndex]}';
}

String generateFileLocalId(String filename) {
  return 'upload_${DateTime.now().microsecondsSinceEpoch}_$filename';
}

String appendFileLink(String existing, String fileLink) {
  final String normalized = existing.trimRight();
  return normalized.isEmpty ? fileLink : '$normalized\n$fileLink';
}

Future<List<PlatformFile>?> pickNonImageFiles() async {
  final FilePickerResult? result = await FilePicker.platform.pickFiles(
    allowMultiple: true,
    withData: kIsWeb,
    type: FileType.custom,
    allowedExtensions: AppConstants.kNonImageAllowedExtensions,
  );

  if (result == null) return null;

  final List<PlatformFile> platformFiles = result.files;

  platformFiles.removeWhere((platformFile) {
    final String extension = extensionOf(platformFile.name);
    if (AppConstants.kImageExtensions.contains(extension)) {
      return true;
    }
    return false;
  });

  return platformFiles;
}

Future<List<XFile>> pickImages() async {
  final bool useImagePicker =
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.macOS;

  if (useImagePicker) {
    final List<XFile> files = (await ImagePicker().pickMultiImage()) ?? const <XFile>[];
    return files;
  } else {
    final FilePickerResult? result = await FilePicker.platform.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions: AppConstants.kImageExtensions,
      withData: false,
    );
    if (result == null) return const <XFile>[];

    return result.files
        .where((file) => file.path != null)
        .map((file) => XFile(file.path!, name: file.name))
        .toList(growable: false);
  }
}

String b64(String value) => base64Encode(utf8.encode(value));

Future<List<PlatformFile>> toPlatformFiles(PerformDropEvent event) async {
  final List<PlatformFile> files = [];

  for (final DropItem dropItem in event.session.items) {
    final reader = dropItem.dataReader!;

    Uri? fileUri;
    if (reader.canProvide(Formats.fileUri)) {
      reader.getValue<Uri>(Formats.fileUri, (uri) {
        fileUri = uri;
      });
    }

    Uint8List? bytes;
    String? name;
    int? size;

    reader.getFile(null, (dataFile) async {
      name = dataFile.fileName;
      size = dataFile.fileSize;
      bytes = await dataFile.readAll();
    });

    name ??= await reader.getSuggestedName() ?? fileUri?.pathSegments.last ?? 'dropped_file';
    size ??= bytes?.lengthInBytes ?? 0;

    final String? path = _tryToFilePath(fileUri);

    files.add(PlatformFile(name: name!, size: size ?? 0, path: path, bytes: bytes));
  }

  return files;
}

String? _tryToFilePath(Uri? uri) {
  if (uri == null || uri.scheme != 'file') return null;
  try {
    return uri.toFilePath();
  } catch (_) {
    return null;
  }
}

String extractMessageText(String content) {
  final RegExp pattern = RegExp(r'\[([^\]]+)\]\(([^)]+)\)');
  final String cleaned = content.replaceAll(pattern, '').trim();
  return cleaned.replaceAll(RegExp(r'\n{2,}'), '\n').trim();
}

bool unorderedEquals<T>(List<T> a, List<T> b) {
  if (a.length != b.length) return false;
  final counts = <T, int>{};
  for (final item in a) {
    counts[item] = (counts[item] ?? 0) + 1;
  }
  for (final item in b) {
    if (!counts.containsKey(item) || counts[item]! == 0) {
      return false;
    }
    counts[item] = counts[item]! - 1;
  }
  return true;
}
