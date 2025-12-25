import 'package:genesis_workspace/data/messages/dto/reaction_dto.dart';

class ReactionEntity {
  final String emojiName;
  final String emojiCode;
  final ReactionType reactionType;
  final int userId;

  ReactionEntity({
    required this.emojiName,
    required this.emojiCode,
    required this.reactionType,
    required this.userId,
  });

  Map<String, dynamic> toJson() => {
    'emoji_name': emojiName,
    'emoji_code': emojiCode,
    'reaction_type': _reactionTypeToJson(reactionType),
    'user_id': userId,
  };

  factory ReactionEntity.fromJson(Map<String, dynamic> json) => ReactionEntity(
    emojiName: json['emoji_name'] as String,
    emojiCode: json['emoji_code'] as String,
    reactionType: _reactionTypeFromJson(json['reaction_type']),
    userId: ((json['user_id'] ?? json['userId']) as num?)?.toInt() ?? -1,
  );

  static ReactionType _reactionTypeFromJson(dynamic value) {
    if (value is ReactionType) {
      return value;
    }
    final String stringValue = value?.toString() ?? '';
    switch (stringValue) {
      case 'unicode_emoji':
        return ReactionType.unicode;
      case 'realm_emoji':
        return ReactionType.realm;
      case 'zulip_extra_emoji':
        return ReactionType.zulip;
      default:
        return ReactionType.unicode;
    }
  }

  static String _reactionTypeToJson(ReactionType reactionType) {
    switch (reactionType) {
      case ReactionType.unicode:
        return 'unicode_emoji';
      case ReactionType.realm:
        return 'realm_emoji';
      case ReactionType.zulip:
        return 'zulip_extra_emoji';
    }
  }
}

class ReactionDetails {
  int count;
  final String emojiName;
  final String emojiCode;
  final List<int> userIds; // Assuming user IDs are integers

  ReactionDetails({
    required this.count,
    required this.userIds,
    required this.emojiName,
    required this.emojiCode,
  });
}
