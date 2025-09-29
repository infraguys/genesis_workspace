import 'package:genesis_workspace/data/all_chats/datasources/folder_local_data_source.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_repository.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: FolderRepository)
class FolderRepositoryImpl implements FolderRepository {
  final FolderLocalDataSource _local;
  FolderRepositoryImpl(this._local);

  @override
  Future<void> addFolder(FolderItemEntity folder) async {
    await _local.add(folder);
  }

  @override
  Future<List<FolderItemEntity>> getFolders() async {
    return _local.getAll();
  }

  @override
  Future<void> updateFolder(FolderItemEntity folder) async {
    await _local.update(folder);
  }

  @override
  Future<void> deleteFolder(int id) async {
    await _local.delete(id);
  }
}
