import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';
import 'package:json_annotation/json_annotation.dart';

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
