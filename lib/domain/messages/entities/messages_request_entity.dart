import 'package:genesis_workspace/data/messages/dto/messages_request_dto.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';

class MessagesRequestEntity {
  final MessageAnchor anchor;
  final List<MessageNarrowEntity>? narrow;
  final int? numBefore;
  final int? numAfter;
  final bool applyMarkdown;
  final bool clientGravatar;
  final bool includeAnchor;

  MessagesRequestEntity({
    required this.anchor,
    this.narrow,
    this.numBefore,
    this.numAfter,
    this.applyMarkdown = true,
    this.clientGravatar = false,
    this.includeAnchor = true,
  });

  MessagesRequestDto toDto() => MessagesRequestDto(
    anchor: anchor.toJson(),
    narrow: narrow?.map((e) => e.toDto()).toList(),
    numBefore: numBefore,
    numAfter: numAfter,
    applyMarkdown: applyMarkdown,
    clientGravatar: clientGravatar,
    includeAnchor: includeAnchor,
  );
}

class MessageAnchor {
  final _AnchorType _type;
  final int? _id;

  const MessageAnchor._(this._type, [this._id]);

  const MessageAnchor.newest() : this._(_AnchorType.newest);
  const MessageAnchor.oldest() : this._(_AnchorType.oldest);
  const MessageAnchor.firstUnread() : this._(_AnchorType.firstUnread);
  const MessageAnchor.id(int id) : this._(_AnchorType.customId, id);

  /// Возвращает строку или число, в зависимости от типа
  dynamic toJson() {
    switch (_type) {
      case _AnchorType.newest:
        return 'newest';
      case _AnchorType.oldest:
        return 'oldest';
      case _AnchorType.firstUnread:
        return 'first_unread';
      case _AnchorType.customId:
        return _id!.toString();
    }
  }
}

enum _AnchorType { newest, oldest, firstUnread, customId }
