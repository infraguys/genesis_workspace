import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/data/all_chats/api/all_chats_api_client.dart';
import 'package:genesis_workspace/data/all_chats/dto/folder_dto.dart';
import 'package:injectable/injectable.dart';

@injectable
class FoldersRemoteDataSource {
  FoldersRemoteDataSource();

  AllChatsApiClient? _apiClient;
  String? _cachedBaseUrl;

  AllChatsApiClient get _apiClientForCurrentOrg {
    final String currentBaseUrl = AppConstants.baseUrl;

    // Пересоздаем клиента только если сменился baseUrl (смена организации).
    if (_apiClient == null || _cachedBaseUrl != currentBaseUrl) {
      _cachedBaseUrl = currentBaseUrl;
      _apiClient = AllChatsApiClient(
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
}
