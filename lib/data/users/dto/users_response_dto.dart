import 'package:json_annotation/json_annotation.dart';

import 'user_dto.dart';

part 'users_response_dto.g.dart';

@JsonSerializable()
class UsersResponseDto {
  final String result;
  final String msg;
  final List<UserDto> members;

  UsersResponseDto({required this.result, required this.msg, required this.members});

  factory UsersResponseDto.fromJson(Map<String, dynamic> json) => _$UsersResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UsersResponseDtoToJson(this);
}
