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
