import 'package:dio/dio.dart';
import 'package:genesis_workspace/data/drafts/dto/create_drafts_dto.dart';
import 'package:genesis_workspace/data/drafts/dto/get_drafts_dto.dart';
import 'package:retrofit/error_logger.dart';
import 'package:retrofit/http.dart';

part 'drafts_api_client.g.dart';

@RestApi(baseUrl: '')
abstract class DraftsApiClient {
  factory DraftsApiClient(Dio dio, {String? baseUrl}) = _DraftsApiClient;

  @GET('/drafts')
  Future<GetDraftsResponseDto> getDrafts();

  @POST('/drafts')
  @FormUrlEncoded()
  Future<CreateDraftsResponseDto> createDrafts(
    @Field('drafts') String draftsJson,
  );

  @PATCH('/drafts/{draft_id}')
  @FormUrlEncoded()
  Future<void> editDraft(
    @Path('draft_id') int draftId,
    @Field('draft') String draft,
  );

  @DELETE('/drafts/{draft_id}')
  Future<void> deleteDraft(
    @Path('draft_id') int draftId,
  );
}
