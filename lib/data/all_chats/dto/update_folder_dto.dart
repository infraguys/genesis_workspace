import 'package:json_annotation/json_annotation.dart';

part 'update_folder_dto.g.dart';

@JsonSerializable()
class UpdateFolderDto {
  const UpdateFolderDto({
    this.title,
    this.backgroundColorValue,
  });

  @JsonKey(name: 'title')
  final String? title;
  @JsonKey(name: 'background_color_value')
  final int? backgroundColorValue;

  Map<String, dynamic> toJson() => _$UpdateFolderDtoToJson(this);
}