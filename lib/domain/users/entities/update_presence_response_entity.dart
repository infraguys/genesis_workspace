import 'package:genesis_workspace/domain/common/entities/response_entity.dart';

class UpdatePresenceResponseEntity extends ResponseEntity {
  int? presenceLastUpdateId;
  UpdatePresenceResponseEntity({
    required super.msg,
    required super.result,
    required this.presenceLastUpdateId,
  });
}
