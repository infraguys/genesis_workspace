import 'package:genesis_workspace/data/messages/dto/messages_request_dto.dart';

class MessagesRequestEntity {
  final int anchor;

  MessagesRequestEntity({required this.anchor});

  MessagesRequestDto toDto() => MessagesRequestDto(anchor: anchor);
}
