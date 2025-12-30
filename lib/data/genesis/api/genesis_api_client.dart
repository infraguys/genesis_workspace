import 'package:dio/dio.dart';
import 'package:genesis_workspace/data/all_chats/dto/folder_dto.dart';
import 'package:genesis_workspace/data/all_chats/dto/folder_item_dto.dart';
import 'package:genesis_workspace/data/genesis/dto/genesis_service_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'genesis_api_client.g.dart';

@RestApi(baseUrl: '')
abstract class GenesisApiClient {
  factory GenesisApiClient(Dio dio, {String? baseUrl}) = _GenesisApiClient;

  @POST('folders/')
  Future<FolderDto> createFolder(@Body() CreateFolderDto body);

  @PUT('folders/{folder_id}')
  Future<FolderDto> updateFolder(@Path('folder_id') String folderId, @Body() UpdateFolderDto body);

  @GET('folders/')
  Future<List<FolderDto>> getFolders();

  @DELETE('folders/{folder_id}')
  Future<void> deleteFolder(@Path('folder_id') String folderId);

  @GET('folders/{folder_uuid}/items/')
  Future<List<FolderItemDto>> getFolderItems(@Path('folder_uuid') String folderUuid);

  @POST('folders/{folder_uuid}/items/')
  Future<FolderItemDto> createFolderItem(
    @Path('folder_uuid') String folderUuid,
    @Body() CreateFolderItemRequest body,
  );

  @DELETE('folders/{folder_uuid}/items/{item_uuid}')
  Future<void> deleteFolderItem(
    @Path('folder_uuid') String folderUuid,
    @Path('item_uuid') String itemUuid,
  );

  @PUT('folders/{folder_uuid}/items/{item_uuid}')
  Future<FolderItemDto> updateFolderItem(
    @Path('folder_uuid') String folderUuid,
    @Path('item_uuid') String itemUuid,
    @Body() UpdateFolderItemRequest body,
  );

  @POST('folders/{folder_uuid}/items/{item_uuid}/actions/pin/invoke')
  Future<void> pinFolderItem(
    @Path('folder_uuid') String folderUuid,
    @Path('item_uuid') String itemUuid,
  );

  @POST('folders/{folder_uuid}/items/{item_uuid}/actions/unpin/invoke')
  Future<void> unpinFolderItem(
    @Path('folder_uuid') String folderUuid,
    @Path('item_uuid') String itemUuid,
  );

  @GET('folder_items/')
  Future<List<FolderItemDto>> getAllFoldersItems();

  @GET('services/')
  Future<List<GenesisServiceDto>> getServices();

  @GET('services/{uuid}')
  Future<GenesisServiceDto> getServiceById(@Path('uuid') String uuid);
}
