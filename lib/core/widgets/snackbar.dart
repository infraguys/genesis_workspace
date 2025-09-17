import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

showErrorSnackBar(BuildContext context, {required DioException exception}) {
  final dynamic data = exception.response?.data;
  final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
  final String errorMessage = (data is Map && data['msg'] is String)
      ? data['msg'] as String
      : context.t.error;
  messenger?.showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
}
