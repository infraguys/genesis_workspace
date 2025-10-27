import 'package:injectable/injectable.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_target.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_membership_repository.dart';

@injectable
class SetFoldersForTargetUseCase {
  final FolderMembershipRepository _repository;
  SetFoldersForTargetUseCase(this._repository);

  Future<void> call(
    FolderTarget target,
    List<int> folderIds, {
    required int organizationId,
  }) async {
    await _repository.setFoldersForTarget(
      target,
      folderIds,
      organizationId: organizationId,
    );
  }
}
