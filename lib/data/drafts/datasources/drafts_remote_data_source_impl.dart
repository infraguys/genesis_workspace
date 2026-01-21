import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/data/drafts/api/drafts_api_client.dart';
import 'package:genesis_workspace/data/drafts/datasources/drafts_remote_data_source.dart';
import 'package:genesis_workspace/data/drafts/dto/create_drafts_dto.dart';
import 'package:genesis_workspace/data/drafts/dto/get_drafts_dto.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: DraftsRemoteDataSource)
class DraftsRemoteDataSourceImpl implements DraftsRemoteDataSource {
  final DraftsApiClient _apiClient = DraftsApiClient(getIt<Dio>());
  DraftsRemoteDataSourceImpl();

  @override
  Future<CreateDraftsResponseDto> createDrafts(CreateDraftsRequestDto body) async {
    final drafts = body.drafts;
    final draftsJson = jsonEncode(drafts.map((e) => e.toJson()).toList());
    return await _apiClient.createDrafts(draftsJson);
  }

  @override
  Future<void> deleteDraft(int id) {
    return _apiClient.deleteDraft(id);
  }

  @override
  Future<void> editDraft() {
    // TODO: implement editDraft
    throw UnimplementedError();
  }

  @override
  Future<GetDraftsResponseDto> getDrafts() async {
    return await _apiClient.getDrafts();
  }
}
