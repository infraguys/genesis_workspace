// auth_interceptor.dart
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BaseUrlInterceptor extends Interceptor {
  final SharedPreferences _prefs;
  BaseUrlInterceptor(this._prefs);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      final bool isWebAuth = _prefs.getBool(SharedPrefsKeys.isWebAuth) ?? false;
      if (isWebAuth && kIsWeb) {
        options.baseUrl = '${AppConstants.baseUrl}/json';
      }
    } catch (e) {
      print('BaseUrlInterceptor error: $e');
    }

    handler.next(options);
  }

  // Убирает дубликаты и двойные разделители в Cookie
  String _normalizeCookie(String cookie) {
    final seen = <String>{};
    final parts = cookie
        .split(';')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .where((e) => seen.add(e))
        .toList();
    return parts.join('; ');
  }
}
