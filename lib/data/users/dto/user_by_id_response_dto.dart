import 'package:genesis_workspace/data/users/dto/user_dto.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_by_id_response_dto.g.dart';

@JsonSerializable()
class UserByIdResponseDto {
  final String msg;
  final String result;
  final UserDto user;

  UserByIdResponseDto({required this.msg, required this.result, required this.user});

  factory UserByIdResponseDto.fromJson(Map<String, dynamic> json) =>
      _$UserByIdResponseDtoFromJson(json);
}
