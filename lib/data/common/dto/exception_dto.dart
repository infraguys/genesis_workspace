import 'package:genesis_workspace/data/common/dto/response_dto.dart';
import 'package:genesis_workspace/domain/common/entities/exception_entity.dart';
import 'package:json_annotation/json_annotation.dart';

part 'exception_dto.g.dart';

@JsonSerializable()
class ServerExceptionDto extends ResponseDto {
  final String? code;
  @JsonKey(name: 'var_name')
  final String? varName;
  final String? parameters;
  @JsonKey(name: 'retry-after')
  final double? retryAfter;

  ServerExceptionDto({
    required super.msg,
    required super.result,
    this.code,
    this.varName,
    this.parameters,
    this.retryAfter,
  });

  factory ServerExceptionDto.fromJson(Map<String, dynamic> json) => _$ServerExceptionDtoFromJson(json);

  Map<String, dynamic> toJson() => <String, dynamic>{
    'msg': msg,
    'result': result,
    if (code != null) 'code': code,
    if (varName != null) 'var_name': varName,
    if (parameters != null) 'parameters': parameters,
    if (retryAfter != null) 'retry-after': retryAfter,
  };

  ServerExceptionEntity toEntity() => ServerExceptionEntity(
    msg: msg,
    result: result,
    code: code,
    varName: varName,
    parameters: parameters,
    retryAfter: retryAfter,
  );
}
