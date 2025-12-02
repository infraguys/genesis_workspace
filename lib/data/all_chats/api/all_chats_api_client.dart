import 'package:dio/dio.dart';
import 'package:genesis_workspace/data/all_chats/dto/folder_dto.dart';
import 'package:retrofit/retrofit.dart';

part 'all_chats_api_client.g.dart';

@RestApi(baseUrl: '')
abstract class AllChatsApiClient {
  factory AllChatsApiClient(Dio dio, {String? baseUrl}) = _AllChatsApiClient;

  @POST('folders/')
  Future<FolderDto> createFolder(@Body() CreateFolderDto body);
}
