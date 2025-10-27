import 'package:genesis_workspace/data/organizations/datasources/organizations_local_data_source.dart';
import 'package:genesis_workspace/domain/organizations/entities/organization_entity.dart';
import 'package:genesis_workspace/domain/organizations/repositories/organizations_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: OrganizationsRepository)
class OrganizationsRepositoryImpl implements OrganizationsRepository {
  final OrganizationsLocalDataSource _localDataSource;

  OrganizationsRepositoryImpl(this._localDataSource);

  @override
  Future<int> addOrganization(OrganizationRequestEntity body) async {
    return await _localDataSource.addOrganization(body.toDto());
  }

  @override
  Future<void> removeOrganization(int id) async {
    return await _localDataSource.removeOrganization(id);
  }

  @override
  Future<List<OrganizationEntity>> getAllOrganizations() async {
    final response = await _localDataSource.getAllOrganizations();
    return response.map((org) => org.toEntity()).toList();
  }
}
