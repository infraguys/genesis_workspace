import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:genesis_workspace/domain/common/entities/exception_entity.dart';
import 'package:genesis_workspace/i18n/generated/strings.g.dart';

showErrorSnackBar(BuildContext context, {required Object exception}) {
  final ScaffoldMessengerState? messenger = ScaffoldMessenger.maybeOf(context);
  String errorMessage = context.t.error;

  if (exception is DioException) {
    final dynamic data = exception.response?.data;
    if (data is Map && data['msg'] is String) {
      errorMessage = data['msg'] as String;
    } else if ((exception.message ?? '').trim().isNotEmpty) {
      errorMessage = exception.message!;
    }
  } else if (exception is ServerExceptionEntity) {
    errorMessage = exception.msg;
  }

  messenger?.showSnackBar(SnackBar(content: Text(errorMessage), backgroundColor: Colors.red));
}
