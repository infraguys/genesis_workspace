import 'dart:async';

import 'package:genesis_workspace/data/organizations/dao/organizations_dao.dart';
import 'package:genesis_workspace/data/organizations/dto/organization_dto.dart';
import 'package:injectable/injectable.dart';

@injectable
class OrganizationsLocalDataSource {
  final OrganizationsDao _dao;

  OrganizationsLocalDataSource(this._dao);

  Future<int> addOrganization(OrganizationRequestDto body) async {
    return _dao.insertOrganization(
      name: body.name,
      icon: body.icon,
      baseUrl: body.baseUrl,
      unreadCount: body.unreadCount,
    );
  }

  Future<void> removeOrganization(int id) async {
    try {
      await _dao.deleteOrganizationById(id);
    } catch (e) {
      rethrow;
    }
  }

  Stream<List<OrganizationDto>> watchOrganizations() {
    return _dao.watchAllOrganizations().map(
          (organizations) => organizations
              .map(
                (org) => OrganizationDto(
                  id: org.id,
                  name: org.name,
                  icon: org.icon,
                  baseUrl: org.baseUrl,
                  unreadCount: org.unreadCount,
                ),
              )
              .toList(),
        );
  }

  Future<List<OrganizationDto>> getAllOrganizations() async {
    try {
      final response = await _dao.getAllOrganizations();
      return response
          .map(
            (org) => OrganizationDto(
              id: org.id,
              name: org.name,
              icon: org.icon,
              baseUrl: org.baseUrl,
              unreadCount: org.unreadCount,
            ),
          )
          .toList();
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
        unreadCount: response.unreadCount,
      );
    } catch (e) {
      rethrow;
    }
  }
}
