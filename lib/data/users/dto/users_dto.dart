import 'package:json_annotation/json_annotation.dart';

import 'user_dto.dart';

part 'users_dto.g.dart';

@JsonSerializable()
class UsersResponseDto {
  final String result;
  final String msg;
  final List<UserDto> members;

  UsersResponseDto({required this.result, required this.msg, required this.members});

  factory UsersResponseDto.fromJson(Map<String, dynamic> json) => _$UsersResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$UsersResponseDtoToJson(this);
}

@JsonSerializable(createFactory: false)
class UsersRequestDto {
  @JsonKey(name: 'user_ids', toJson: _idsToCsv)
  final List<int>? userIds;

  UsersRequestDto({required this.userIds});

  Map<String, dynamic> toJson() => _$UsersRequestDtoToJson(this);

  static String? _idsToCsv(List<int>? ids) => ids != null ? '[${ids.join(',')}]' : null;

  String? get userIdsString => _idsToCsv(userIds);
}
