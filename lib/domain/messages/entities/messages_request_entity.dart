import 'package:genesis_workspace/data/messages/dto/messages_request_dto.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';

class MessagesRequestEntity {
  final MessageAnchor anchor;
  final List<MessageNarrowEntity>? narrow;

  MessagesRequestEntity({required this.anchor, this.narrow});

  MessagesRequestDto toDto() =>
      MessagesRequestDto(anchor: anchor.name, narrow: narrow?.map((e) => e.toDto()).toList());
}

enum MessageAnchor { newest, oldest, first_unread }
