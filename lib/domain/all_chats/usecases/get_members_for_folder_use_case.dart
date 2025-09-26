import 'package:genesis_workspace/domain/all_chats/entities/folder_members.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_membership_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetMembersForFolderUseCase {
  final FolderMembershipRepository _repository;
  GetMembersForFolderUseCase(this._repository);

  Future<FolderMembers> call(int folderId) async {
    return _repository.getMembersForFolder(folderId);
  }
}
