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
    final entity = response.toEntity();
    final orgId = AppConstants.selectedOrganizationId ?? -1;
    await _localDataSource.add(entity, organizationId: orgId);
    return entity;
  }

  @override
  Future<List<FolderEntity>> getFolders(int organizationId) async {
    final response = await _remoteDataSource.getAll();
    final entities = response.map((folder) => folder.toEntity()).toList();
    await _localDataSource.replaceAll(entities, organizationId: organizationId);
    return entities;
  }

  @override
  Future<FolderEntity> updateFolder(UpdateFolderEntity folder) async {
    final updated = await _remoteDataSource.update(folder.uuid, folder: folder.toDto());
    final orgId = AppConstants.selectedOrganizationId ?? -1;
    await _localDataSource.add(updated, organizationId: orgId);
    return updated;
  }

  @override
  Future<void> deleteFolder(DeleteFolderEntity folder) async {
    await _remoteDataSource.delete(folder.folderId);
    await _localDataSource.delete(folder.folderId);
  }
}
