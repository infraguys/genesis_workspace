// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upload_file_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UploadFileResponseDto _$UploadFileResponseDtoFromJson(
  Map<String, dynamic> json,
) => UploadFileResponseDto(
  msg: json['msg'] as String,
  result: json['result'] as String,
  url: json['url'] as String,
  uri: json['uri'] as String?,
  filename: json['filename'] as String,
);

Map<String, dynamic> _$UploadFileResponseDtoToJson(
  UploadFileResponseDto instance,
) => <String, dynamic>{
  'msg': instance.msg,
  'result': instance.result,
  'url': instance.url,
  'uri': instance.uri,
  'filename': instance.filename,
};
