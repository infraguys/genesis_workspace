import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/data/all_chats/datasources/folder_local_data_source.dart';
import 'package:genesis_workspace/data/all_chats/datasources/folders_remote_data_source.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:genesis_workspace/domain/all_chats/repositories/folder_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: FolderRepository)
class FolderRepositoryImpl implements FolderRepository {
  final FolderLocalDataSource _localDataSource;
  final FoldersRemoteDataSource _remoteDataSource;
  FolderRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  Future<FolderEntity> addFolder(CreateFolderEntity folder) async {
    final response = await _remoteDataSource.add(folder.toDto());
    return response.toEntity();
    // final entity = response;
    // await _localDataSource.add(entity);
  }

  @override
  Future<List<FolderEntity>> getFolders(int organizationId) async {
    final response = await _remoteDataSource.getAll();
    final organizationId = AppConstants.selectedOrganizationId;
    if (organizationId != null) {
      return response.map((folder) => folder.toEntity()).toList();
    }
    return [];
  }

  @override
  Future<FolderEntity> updateFolder(UpdateFolderEntity folder) async {
    return await _remoteDataSource.update(folder.uuid, folder: folder.toDto());
  }

  @override
  Future<void> deleteFolder(int id) async {
    await _localDataSource.delete(id);
  }
}
