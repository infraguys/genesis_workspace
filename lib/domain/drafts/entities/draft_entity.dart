import 'package:collection/collection.dart';
import 'package:genesis_workspace/core/enums/draft_type.dart';
import 'package:genesis_workspace/data/drafts/dto/draft_dto.dart';

class DraftEntity {
  final int? id;
  final DraftType type;
  final List<int> to;
  final String topic;
  final String content;
  final int? timestamp;

  DraftEntity({
    this.id,
    required this.type,
    required this.to,
    required this.topic,
    required this.content,
    this.timestamp,
  });

  DraftDto toDto() => DraftDto(id: id, type: type, to: to, topic: topic, content: content, timestamp: timestamp);

  DraftEntity copyWith({
    int? id,
    DraftType? type,
    List<int>? to,
    String? topic,
    String? content,
    int? timestamp,
    int? chatId,
  }) {
    return DraftEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      to: to ?? this.to,
      topic: topic ?? this.topic,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

extension DraftEntityMatcher on DraftEntity {
  static const ListEquality<int> _listEquals = ListEquality<int>();
  static const SetEquality<int> _setEquals = SetEquality<int>();

  bool matchesUsers(List<int> userIds) {
    return _setEquals.equals(to.toSet(), userIds.toSet());
  }

  bool matchesChannel({
    required int channelId,
    String? topicName,
  }) {
    final bool channelMatches = _listEquals.equals(to, [channelId]);

    if (!channelMatches) {
      return false;
    }

    if (topicName != null) {
      return topic == topicName;
    }

    return true;
  }
}
