import 'package:genesis_workspace/core/enums/folder_system_type.dart';
import 'package:json_annotation/json_annotation.dart';

part 'folder_dto.g.dart';

@JsonSerializable()
class CreateFolderDto {
  final String title;

  @JsonKey(name: 'background_color_value')
  final int backgroundColorValue;

  @JsonKey(name: 'unread_messages')
  final List<int> unreadMessages;

  @JsonKey(name: 'system_type')
  final FolderSystemType systemType;

  const CreateFolderDto({
    required this.title,
    required this.backgroundColorValue,
    this.unreadMessages = const <int>[],
    required this.systemType,
  });

  factory CreateFolderDto.fromJson(Map<String, dynamic> json) => _$CreateFolderDtoFromJson(json);

  Map<String, dynamic> toJson() => _$CreateFolderDtoToJson(this);
}
