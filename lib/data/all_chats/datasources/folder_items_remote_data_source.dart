import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/data/all_chats/dto/folder_item_dto.dart';
import 'package:genesis_workspace/data/genesis/api/genesis_api_client.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_item_entity.dart';
import 'package:injectable/injectable.dart';

@injectable
class FolderItemsRemoteDataSource {
  FolderItemsRemoteDataSource();

  GenesisApiClient? _apiClient;
  String? _cachedBaseUrl;

  GenesisApiClient get _client {
    final currentBaseUrl = AppConstants.baseUrl;
    if (_apiClient == null || _cachedBaseUrl != currentBaseUrl) {
      _cachedBaseUrl = currentBaseUrl;
      _apiClient = GenesisApiClient(
        getIt<Dio>(),
        baseUrl: "$currentBaseUrl/workspace/v1/",
      );
    }
    return _apiClient!;
  }

  Future<List<FolderItemEntity>> getFolderItems(String folderUuid) async {
    final items = await _client.getFolderItems(folderUuid);
    return items.map((e) => e.toEntity()).toList();
  }

  Future<List<FolderItemEntity>> getAllFoldersItems() async {
    final items = await _client.getAllFoldersItems();
    return items.map((e) => e.toEntity()).toList();
  }

  Future<FolderItemEntity> createFolderItem({
    required String folderUuid,
    required int chatId,
    int? orderIndex,
  }) async {
    final created = await _client.createFolderItem(
      folderUuid,
      CreateFolderItemRequest(chatId: chatId, orderIndex: orderIndex),
    );
    return created.toEntity();
  }

  Future<void> deleteFolderItem({
    required String folderUuid,
    required String folderItemUuid,
  }) async {
    await _client.deleteFolderItem(folderUuid, folderItemUuid);
  }

  Future<void> pinFolderItem({
    required String folderUuid,
    required String folderItemUuid,
  }) async {
    await _client.pinFolderItem(folderUuid, folderItemUuid);
  }

  Future<void> unpinFolderItem({
    required String folderUuid,
    required String folderItemUuid,
  }) async {
    await _client.unpinFolderItem(folderUuid, folderItemUuid);
  }

  Future<void> updateFolderItem({
    required String folderUuid,
    required String folderItemUuid,
    int? orderIndex,
  }) async {
    await _client.updateFolderItem(
      folderUuid,
      folderItemUuid,
      UpdateFolderItemRequest(orderIndex: orderIndex),
    );
  }

  Future<FolderItemEntity?> findFolderItem(String folderUuid, int chatId) async {
    final items = await getFolderItems(folderUuid);
    try {
      return items.firstWhere((item) => item.chatId == chatId);
    } catch (_) {
      return null;
    }
  }

  Future<FolderItemEntity> ensureFolderItem(String folderUuid, int chatId) async {
    final existing = await findFolderItem(folderUuid, chatId);
    if (existing != null) return existing;
    return await createFolderItem(folderUuid: folderUuid, chatId: chatId);
  }
}
