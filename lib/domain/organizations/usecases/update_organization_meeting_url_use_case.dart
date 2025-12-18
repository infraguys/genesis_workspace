import 'package:genesis_workspace/domain/organizations/repositories/organizations_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateOrganizationMeetingUrlUseCase {
  UpdateOrganizationMeetingUrlUseCase(this._repository);

  final OrganizationsRepository _repository;

  Future<void> call({
    required int organizationId,
    required String? meetingUrl,
  }) {
    return _repository.updateMeetingUrl(
      organizationId: organizationId,
      meetingUrl: meetingUrl,
    );
  }
}
