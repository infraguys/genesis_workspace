import 'package:genesis_workspace/data/drafts/datasources/drafts_remote_data_source.dart';
import 'package:genesis_workspace/domain/drafts/entities/create_drafts_entity.dart';
import 'package:genesis_workspace/domain/drafts/entities/edit_draft_entity.dart';
import 'package:genesis_workspace/domain/drafts/entities/get_drafts_entity.dart';
import 'package:genesis_workspace/domain/drafts/repositories/drafts_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: DraftsRepository)
class DraftsRepositoryImpl implements DraftsRepository {
  final DraftsRemoteDataSource _dataSource;
  DraftsRepositoryImpl(this._dataSource);

  @override
  Future<CreateDraftsResponseEntity> createDrafts(CreateDraftsRequestEntity body) async {
    final response = await _dataSource.createDrafts(body.toDto());
    return response.toEntity();
  }

  @override
  Future<void> deleteDraft(int id) async {
    return await _dataSource.deleteDraft(id);
  }

  @override
  Future<void> editDraft(EditDraftRequestEntity body) async {
    return await _dataSource.editDraft(body.toDto());
  }

  @override
  Future<GetDraftsResponseEntity> getDrafts() async {
    final response = await _dataSource.getDrafts();
    return response.toEntity();
  }
}
