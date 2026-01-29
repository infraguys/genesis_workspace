import 'package:genesis_workspace/domain/common/entities/response_entity.dart';

class ServerExceptionEntity extends ResponseEntity {
  ServerExceptionEntity({
    required super.msg,
    required super.result,
    this.code,
    this.varName,
    this.parameters,
    this.retryAfter,
  });
  final String? code;
  final String? varName;
  final String? parameters;
  final double? retryAfter;
}
