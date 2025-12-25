import 'package:genesis_workspace/domain/all_chats/entities/folder_item_entity.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_membership_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAllFoldersItemsUseCase {
  final FolderMembershipRepository _repository;
  GetAllFoldersItemsUseCase(this._repository);

  Future<List<FolderItemEntity>> call() async {
    return await _repository.getAllFoldersItems();
  }
}
