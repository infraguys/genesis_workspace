import 'package:genesis_workspace/data/all_chats/datasources/folder_local_data_source.dart';
import 'package:genesis_workspace/data/all_chats/datasources/folders_remote_data_source.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_repository.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: FolderRepository)
class FolderRepositoryImpl implements FolderRepository {
  final FolderLocalDataSource _localDataSource;
  final FoldersRemoteDataSource _remoteDataSource;
  FolderRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<void> addFolder(CreateFolderEntity folder) async {
    final response = await _remoteDataSource.add(folder.toDto());
    final entity = response.toEntity(null);
    await _localDataSource.add(entity);
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
