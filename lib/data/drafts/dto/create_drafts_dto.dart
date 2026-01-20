import 'package:genesis_workspace/data/common/dto/response_dto.dart';
import 'package:genesis_workspace/data/drafts/dto/draft_dto.dart';
import 'package:genesis_workspace/domain/drafts/entities/create_drafts_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'create_drafts_dto.g.dart';

@JsonSerializable()
class CreateDraftsResponseDto extends ResponseDto {
  final List<int> ids;
  CreateDraftsResponseDto({required super.msg, required super.result, required this.ids});

  factory CreateDraftsResponseDto.fromJson(Map<String, dynamic> json) => _$CreateDraftsResponseDtoFromJson(json);

  CreateDraftsResponseEntity toEntity() => CreateDraftsResponseEntity(msg: msg, result: result, ids: ids);
}

@JsonSerializable()
class CreateDraftsRequestDto {
  final List<DraftDto> drafts;

  CreateDraftsRequestDto({required this.drafts});

  Map<String, dynamic> toJson() => _$CreateDraftsRequestDtoToJson(this);
}
