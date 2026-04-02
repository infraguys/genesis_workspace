import 'package:genesis_workspace/domain/organizations/entities/server_emoji_list_entity.dart';
import 'package:genesis_workspace/domain/organizations/repositories/organizations_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetOrganizationEmojiListUseCase {
  final OrganizationsRepository _repository;
  GetOrganizationEmojiListUseCase(this._repository);

  Future<ServerEmojiListEntity> call(String url) async {
    return await _repository.getOrganizationEmojiList(url);
  }
}
