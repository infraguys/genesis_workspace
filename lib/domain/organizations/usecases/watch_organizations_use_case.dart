import 'dart:async';

import 'package:genesis_workspace/domain/organizations/entities/organization_entity.dart';
import 'package:genesis_workspace/domain/organizations/repositories/organizations_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class WatchOrganizationsUseCase {
  WatchOrganizationsUseCase(this._repository);

  final OrganizationsRepository _repository;

  Stream<List<OrganizationEntity>> call() {
    return _repository.watchOrganizations();
  }
}
