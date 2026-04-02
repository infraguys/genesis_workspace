import 'package:genesis_workspace/domain/organizations/repositories/organizations_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateOrganizationEmojiServerUrlUseCase {
  UpdateOrganizationEmojiServerUrlUseCase(this._repository);

  final OrganizationsRepository _repository;

  Future<void> call({
    required int organizationId,
    required String? emojiServerUrl,
  }) {
    return _repository.updateEmojiServerUrl(
      organizationId: organizationId,
      emojiServerUrl: emojiServerUrl,
    );
  }
}
