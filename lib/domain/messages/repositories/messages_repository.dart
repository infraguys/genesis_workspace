import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_response_entity.dart';

abstract class MessagesRepository {
  Future<MessagesResponseEntity> getMessages(MessagesRequestEntity body);
}
