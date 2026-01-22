import 'package:genesis_workspace/domain/drafts/entities/create_drafts_entity.dart';
import 'package:genesis_workspace/domain/drafts/repositories/drafts_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class CreateDraftsUseCase {
  final DraftsRepository _repository;
  CreateDraftsUseCase(this._repository);

  Future<CreateDraftsResponseEntity> call(CreateDraftsRequestEntity body) async {
    return await _repository.createDrafts(body);
  }
}
