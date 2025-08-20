import 'package:dio/dio.dart';
import 'package:dio/io.dart';

HttpClientAdapter? createPlatformAdapter() {
  final adapter = IOHttpClientAdapter();
  return adapter;
}
