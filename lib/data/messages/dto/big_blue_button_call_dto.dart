import 'package:genesis_workspace/data/common/dto/response_dto.dart';
import 'package:genesis_workspace/domain/messages/entities/big_blue_button_call_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'big_blue_button_call_dto.g.dart';

@JsonSerializable(explicitToJson: true)
class BigBlueButtonCallResponseDto extends ResponseDto {
  @JsonKey(name: "url")
  final String url;
  BigBlueButtonCallResponseDto({
    required super.msg,
    required super.result,
    required this.url,
  });

  factory BigBlueButtonCallResponseDto.fromJson(Map<String, dynamic> json) =>
      _$BigBlueButtonCallResponseDtoFromJson(json);

  BigBlueButtonCallResponseEntity toEntity() => BigBlueButtonCallResponseEntity(
    msg: msg,
    result: result,
    url: url,
  );
}

class BigBlueButtonCallRequestDto {
  final String callName;
  final bool voiceOnly;

  BigBlueButtonCallRequestDto({required this.callName, this.voiceOnly = true});
}
