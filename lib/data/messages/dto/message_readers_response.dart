import 'package:genesis_workspace/data/common/dto/response_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'message_readers_response.g.dart';

@JsonSerializable(createToJson: false)
class MessageReadersResponse extends ResponseDto {
  MessageReadersResponse({
    required super.msg,
    required super.result,
    required this.userIds,
  });

  @JsonKey(name: 'user_ids')
  final List<int> userIds;

  factory MessageReadersResponse.fromJson(Map<String, dynamic> json) =>
      _$MessageReadersResponseFromJson(json);
}
