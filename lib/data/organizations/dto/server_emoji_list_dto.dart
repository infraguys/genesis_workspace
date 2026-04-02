import 'package:genesis_workspace/domain/organizations/entities/server_emoji_list_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'server_emoji_list_dto.g.dart';

@JsonSerializable()
class ServerEmojiListDto {
  const ServerEmojiListDto({
    required this.codeToNames,
  });

  @JsonKey(name: 'code_to_names')
  final Map<String, List<String>> codeToNames;

  factory ServerEmojiListDto.fromJson(Map<String, dynamic> json) => _$ServerEmojiListDtoFromJson(json);

  Map<String, dynamic> toJson() => _$ServerEmojiListDtoToJson(this);

  ServerEmojiListEntity toEntity() => ServerEmojiListEntity(
    emojiList: codeToNames.entries
        .map(
          (entry) => ServerEmojiEntity(
            emojiCode: entry.key,
            emojiNames: entry.value,
          ),
        )
        .toList(),
  );
}
