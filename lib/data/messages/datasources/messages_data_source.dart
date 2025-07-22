import 'package:genesis_workspace/data/messages/dto/messages_request_dto.dart';
import 'package:genesis_workspace/data/messages/dto/messages_response_dto.dart';
import 'package:genesis_workspace/data/messages/dto/send_message_request_dto.dart';
import 'package:genesis_workspace/data/messages/dto/update_messages_flags_request_dto.dart';

abstract class MessagesDataSource {
  Future<MessagesResponseDto> getMessages(MessagesRequestDto body);
  Future<void> sendMessage(SendMessageRequestDto body);
  Future<void> updateMessagesFlags(UpdateMessagesFlagsRequestDto body);
}
