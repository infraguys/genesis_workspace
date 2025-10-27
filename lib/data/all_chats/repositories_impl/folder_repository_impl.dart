import 'package:genesis_workspace/data/all_chats/datasources/folder_local_data_source.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_repository.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: FolderRepository)
class FolderRepositoryImpl implements FolderRepository {
  final FolderLocalDataSource _localDataSource;
  FolderRepositoryImpl(this._localDataSource);

  @override
  Future<void> addFolder(FolderItemEntity folder) async {
    await _localDataSource.add(folder);
  }

  @override
  Future<List<Folder>> getFolders(int organizationId) async {
    return _localDataSource.getAll(organizationId);
  }

  @override
  Future<void> updateFolder(FolderItemEntity folder) async {
    await _localDataSource.update(folder);
  }

  @override
  Future<void> deleteFolder(int id) async {
    await _localDataSource.delete(id);
  }
}
