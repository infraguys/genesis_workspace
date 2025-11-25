import 'package:genesis_workspace/data/messages/dto/big_blue_button_call_dto.dart';
import 'package:genesis_workspace/domain/common/entities/response_entity.dart';

class BigBlueButtonCallResponseEntity extends ResponseEntity {
  final String url;

  BigBlueButtonCallResponseEntity({
    required super.msg,
    required super.result,
    required this.url,
  });
}

class BigBlueButtonCallRequestEntity {
  final String callName;
  final bool voiceOnly;

  BigBlueButtonCallRequestEntity({required this.callName, this.voiceOnly = true});

  BigBlueButtonCallRequestDto toDto() => BigBlueButtonCallRequestDto(
    callName: callName,
    voiceOnly: voiceOnly,
  );
}
