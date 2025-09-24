import 'package:injectable/injectable.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_membership_repository.dart';

@injectable
class RemoveAllMembershipsForFolderUseCase {
  final FolderMembershipRepository _repository;
  RemoveAllMembershipsForFolderUseCase(this._repository);

  Future<void> call(int folderId) => _repository.removeAllForFolder(folderId);
}

