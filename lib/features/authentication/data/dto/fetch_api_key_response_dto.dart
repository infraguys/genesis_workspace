import 'package:json_annotation/json_annotation.dart';

part 'fetch_api_key_response_dto.g.dart';

@JsonSerializable()
class FetchApiKeyResponseDto {
  @JsonKey(name: 'api_key')
  final String apiKey;

  final String email;
  final String msg;
  final String result;

  @JsonKey(name: 'user_id')
  final int userId;

  FetchApiKeyResponseDto({
    required this.apiKey,
    required this.email,
    required this.msg,
    required this.result,
    required this.userId,
  });

  factory FetchApiKeyResponseDto.fromJson(Map<String, dynamic> json) =>
      _$FetchApiKeyResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$FetchApiKeyResponseDtoToJson(this);
}
