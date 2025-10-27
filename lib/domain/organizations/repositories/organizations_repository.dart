import 'package:genesis_workspace/domain/organizations/entities/organization_entity.dart';

abstract class OrganizationsRepository {
  Future<int> addOrganization(OrganizationRequestEntity body);

  Future<void> removeOrganization(int id);

  Future<List<OrganizationEntity>> getAllOrganizations();

  Future<OrganizationEntity> getOrganizationById(int id);

  Stream<List<OrganizationEntity>> watchOrganizations();
}
