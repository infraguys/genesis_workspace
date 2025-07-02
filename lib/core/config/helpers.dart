import 'dart:convert';

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
