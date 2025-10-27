import 'package:genesis_workspace/data/organizations/dao/organizations_dao.dart';
import 'package:genesis_workspace/data/organizations/dto/organization_dto.dart';
import 'package:injectable/injectable.dart';

@injectable
class OrganizationsLocalDataSource {
  final OrganizationsDao _dao;
  OrganizationsLocalDataSource(this._dao);

  Future<int> addOrganization(OrganizationRequestDto body) async {
    return await _dao.insertOrganization(name: body.name, icon: body.icon, baseUrl: body.baseUrl);
  }

  Future<void> removeOrganization(int id) async {
    try {
      await _dao.deleteOrganizationById(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<OrganizationDto>> getAllOrganizations() async {
    try {
      final response = await _dao.getAllOrganizations();
      List<OrganizationDto> organizations = response
          .map(
            (org) =>
                OrganizationDto(id: org.id, name: org.name, icon: org.icon, baseUrl: org.baseUrl),
          )
          .toList();
      return organizations;
    } catch (e) {
      rethrow;
    }
  }

  Future<OrganizationDto> getOrganizationById(int id) async {
    try {
      final response = await _dao.getOrganizationById(id);
      if (response == null) {
        throw Exception('Organization not found');
      }
      return OrganizationDto(
        id: response.id,
        name: response.name,
        icon: response.icon,
        baseUrl: response.baseUrl,
      );
    } catch (e) {
      rethrow;
    }
  }
}
