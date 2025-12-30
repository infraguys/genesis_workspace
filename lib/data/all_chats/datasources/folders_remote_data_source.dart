import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/data/all_chats/dto/folder_dto.dart';
import 'package:genesis_workspace/data/genesis/api/genesis_api_client.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class FoldersRemoteDataSource {
  FoldersRemoteDataSource();

  GenesisApiClient? _apiClient;
  String? _cachedBaseUrl;

  GenesisApiClient get _apiClientForCurrentOrg {
    final String currentBaseUrl = AppConstants.baseUrl;

    // Пересоздаем клиента только если сменился baseUrl (смена организации).
    if (_apiClient == null || _cachedBaseUrl != currentBaseUrl) {
      _cachedBaseUrl = currentBaseUrl;
      _apiClient = GenesisApiClient(
        getIt<Dio>(),
        baseUrl: "$currentBaseUrl/workspace/v1/",
      );
    }

    return _apiClient!;
  }

  Future<FolderDto> add(CreateFolderDto folder) async {
    try {
      final response = await _apiClientForCurrentOrg.createFolder(folder);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<FolderDto>> getAll() async {
    try {
      final response = await _apiClientForCurrentOrg.getFolders();
      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<FolderEntity> update(String folderId, {required UpdateFolderDto folder}) async {
    try {
      final response = await _apiClientForCurrentOrg.updateFolder(folderId, folder);
      return response.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> delete(String folderId) async {
    try {
      await _apiClientForCurrentOrg.deleteFolder(folderId);
    } catch (e) {
      rethrow;
    }
  }
}
