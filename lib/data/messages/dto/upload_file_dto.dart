import 'package:file_picker/file_picker.dart';
import 'package:genesis_workspace/data/common/dto/response_dto.dart';
import 'package:genesis_workspace/domain/messages/entities/upload_file_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'upload_file_dto.g.dart';

@JsonSerializable()
class UploadFileResponseDto extends ResponseDto {
  final String url;
  final String? uri;
  final String filename;

  UploadFileResponseDto({
    required super.msg,
    required super.result,
    required this.url,
    this.uri,
    required this.filename,
  });
  factory UploadFileResponseDto.fromJson(Map<String, dynamic> json) => _$UploadFileResponseDtoFromJson(json);

  UploadFileResponseEntity toEntity() =>
      UploadFileResponseEntity(msg: msg, result: result, url: url, filename: filename);
}

class UploadFileRequestDto {
  final PlatformFile file;
  UploadFileRequestDto({required this.file});
}
