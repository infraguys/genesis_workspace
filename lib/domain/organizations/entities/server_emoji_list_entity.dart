class ServerEmojiListEntity {
  final List<ServerEmojiEntity> emojiList;
  ServerEmojiListEntity({required this.emojiList});
}

class ServerEmojiEntity {
  final String emojiCode;
  final List<String> emojiNames;

  ServerEmojiEntity({
    required this.emojiCode,
    required this.emojiNames,
  });
}
