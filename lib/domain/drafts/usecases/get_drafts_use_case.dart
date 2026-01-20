import 'package:genesis_workspace/domain/drafts/entities/get_drafts_entity.dart';
import 'package:genesis_workspace/domain/drafts/repositories/drafts_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetDraftsUseCase {
  final DraftsRepository _repository;
  GetDraftsUseCase(this._repository);

  Future<GetDraftsResponseEntity> call() async {
    return await _repository.getDrafts();
  }
}
