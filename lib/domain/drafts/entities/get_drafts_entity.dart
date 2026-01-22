import 'package:genesis_workspace/domain/common/entities/response_entity.dart';
import 'package:genesis_workspace/domain/drafts/entities/draft_entity.dart';

class GetDraftsResponseEntity extends ResponseEntity {
  final int count;
  final List<DraftEntity> drafts;
  GetDraftsResponseEntity({required super.msg, required super.result, required this.drafts, required this.count});
}
