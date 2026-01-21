import 'package:genesis_workspace/data/drafts/datasources/drafts_remote_data_source.dart';
import 'package:genesis_workspace/domain/drafts/entities/create_drafts_entity.dart';
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
  Future<void> deleteDraft(int id) {
    return _dataSource.deleteDraft(id);
  }

  @override
  Future<void> editDraft() {
    // TODO: implement editDraft
    throw UnimplementedError();
  }

  @override
  Future<GetDraftsResponseEntity> getDrafts() async {
    final response = await _dataSource.getDrafts();
    return response.toEntity();
  }
}
