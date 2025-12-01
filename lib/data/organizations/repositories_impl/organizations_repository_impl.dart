import 'package:genesis_workspace/data/organizations/datasources/organizations_data_source.dart';
import 'package:genesis_workspace/data/organizations/datasources/organizations_local_data_source.dart';
import 'package:genesis_workspace/domain/organizations/entities/organization_entity.dart';
import 'package:genesis_workspace/domain/organizations/repositories/organizations_repository.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/server_settings_entity.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: OrganizationsRepository)
class OrganizationsRepositoryImpl implements OrganizationsRepository {
  final OrganizationsLocalDataSource _localDataSource;
  final OrganizationsDataSource _dataSource;

  OrganizationsRepositoryImpl(this._localDataSource, this._dataSource);

  @override
  Future<OrganizationEntity> addOrganization(OrganizationRequestEntity body) async {
    final dto = await _localDataSource.addOrganization(body.toDto());
    return dto.toEntity();
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

  @override
  Future<OrganizationEntity> getOrganizationById(int id) async {
    final response = await _localDataSource.getOrganizationById(id);
    return response.toEntity();
  }

  @override
  Stream<List<OrganizationEntity>> watchOrganizations() {
    return _localDataSource.watchOrganizations().map(
      (organizations) => organizations.map((org) => org.toEntity()).toList(),
    );
  }

  @override
  Future<ServerSettingsEntity> getOrganizationSettings(String url) async {
    try {
      final dto = await _dataSource.getOrganizationSettings(url);
      return dto.toEntity();
    } catch (e) {
      rethrow;
    }
  }
}
