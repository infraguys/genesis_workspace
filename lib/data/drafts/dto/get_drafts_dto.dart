import 'package:genesis_workspace/data/common/dto/response_dto.dart';
import 'package:genesis_workspace/data/drafts/dto/draft_dto.dart';
import 'package:genesis_workspace/domain/drafts/entities/get_drafts_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'get_drafts_dto.g.dart';

@JsonSerializable()
class GetDraftsResponseDto extends ResponseDto {
  final int count;
  final List<DraftDto> drafts;
  GetDraftsResponseDto({required super.msg, required super.result, required this.count, required this.drafts});

  factory GetDraftsResponseDto.fromJson(Map<String, dynamic> json) => _$GetDraftsResponseDtoFromJson(json);

  GetDraftsResponseEntity toEntity() => GetDraftsResponseEntity(
    msg: msg,
    result: result,
    drafts: drafts.map((draft) => draft.toEntity()).toList(),
    count: count,
  );
}
