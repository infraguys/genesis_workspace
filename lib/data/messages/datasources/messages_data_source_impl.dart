import 'dart:convert';
import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/data/messages/api/messages_api_client.dart';
import 'package:genesis_workspace/data/messages/datasources/messages_data_source.dart';
import 'package:genesis_workspace/data/messages/dto/messages_request_dto.dart';
import 'package:genesis_workspace/data/messages/dto/messages_response_dto.dart';
import 'package:genesis_workspace/data/messages/dto/send_message_request_dto.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: MessagesDataSource)
class MessagesDataSourceImpl implements MessagesDataSource {
  final MessagesApiClient apiClient = MessagesApiClient(getIt<Dio>());

  @override
  Future<MessagesResponseDto> getMessages(MessagesRequestDto body) async {
    try {
      final anchor = body.anchor;
      final narrowString = jsonEncode(body.narrow?.map((e) => e.toJson()).toList());
      return await apiClient.getMessages(
        anchor,
        narrowString,
        body.numBefore,
        body.numAfter,
        false,
      );
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> sendMessage(SendMessageRequestDto body) async {
    try {
      inspect(jsonEncode(body.to));
      await apiClient.sendMessage(body.type, jsonEncode(body.to), body.content);
    } catch (e) {
      rethrow;
    }
  }
}
