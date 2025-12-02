import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/data/all_chats/api/all_chats_api_client.dart';
import 'package:genesis_workspace/data/all_chats/dto/folder_dto.dart';
import 'package:injectable/injectable.dart';

@injectable
class FoldersRemoteDataSource {
  final AllChatsApiClient _apiClient = AllChatsApiClient(
    getIt<Dio>(),
    baseUrl: "${AppConstants.baseUrl}/workspace/api/v1/",
  );
  FoldersRemoteDataSource();

  Future<void> add(CreateFolderDto folder) async {
    try {
      final response = await _apiClient.createFolder(folder);
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
