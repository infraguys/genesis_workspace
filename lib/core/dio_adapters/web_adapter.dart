// ignore: avoid_web_libraries_in_flutter
import 'package:dio/browser.dart';
import 'package:dio/dio.dart';

HttpClientAdapter? createPlatformAdapter() {
  final adapter = BrowserHttpClientAdapter();
  adapter.withCredentials = true;
  return adapter;
}
