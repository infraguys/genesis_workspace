import 'package:genesis_workspace/data/messages/dto/messages_request_dto.dart';
import 'package:genesis_workspace/data/messages/dto/messages_response_dto.dart';

abstract class MessagesDataSource {
  Future<MessagesResponseDto> getMessages(MessagesRequestDto body);
}
