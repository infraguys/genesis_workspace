import 'dart:convert';

import 'package:flutter/material.dart';
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
