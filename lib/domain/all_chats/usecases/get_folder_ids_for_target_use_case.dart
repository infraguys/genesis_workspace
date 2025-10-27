import 'package:injectable/injectable.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_target.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_membership_repository.dart';

@injectable
class GetFolderIdsForTargetUseCase {
  final FolderMembershipRepository _repository;
  GetFolderIdsForTargetUseCase(this._repository);

  Future<List<int>> call(
    FolderTarget target, {
    required int organizationId,
  }) async {
    return _repository.getFolderIdsForTarget(
      target,
      organizationId: organizationId,
    );
  }
}
