import 'dart:async';

import 'package:genesis_workspace/data/organizations/dao/organizations_dao.dart';
import 'package:genesis_workspace/data/organizations/dto/organization_dto.dart';
import 'package:injectable/injectable.dart';

@injectable
class OrganizationsLocalDataSource {
  final OrganizationsDao _dao;

  OrganizationsLocalDataSource(this._dao);

  Future<OrganizationDto> addOrganization(OrganizationRequestDto body) async {
    final int id = await _dao.insertOrganization(
      name: body.name,
      icon: body.icon,
      baseUrl: body.baseUrl,
      unreadMessages: body.unreadMessages,
      meetingUrl: body.meetingUrl,
    );
    return OrganizationDto(
      id: id,
      name: body.name,
      icon: body.icon,
      baseUrl: body.baseUrl,
      unreadMessages: body.unreadMessages,
      meetingUrl: body.meetingUrl,
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
              unreadMessages: org.unreadMessages,
              meetingUrl: org.meetingUrl,
              streamNameMaxLength: org.maxStreamNameLength,
              streamDescriptionMaxLength: org.maxStreamDescriptionLength,
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
              unreadMessages: org.unreadMessages,
              meetingUrl: org.meetingUrl,
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
        unreadMessages: response.unreadMessages,
        meetingUrl: response.meetingUrl,
        streamNameMaxLength: response.maxStreamNameLength,
        streamDescriptionMaxLength: response.maxStreamDescriptionLength,
      );
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateMeetingUrl({
    required int organizationId,
    required String? meetingUrl,
  }) {
    return _dao.updateMeetingUrl(
      organizationId: organizationId,
      meetingUrl: meetingUrl,
    );
  }

  Future<void> updateStreamSettings({
    required int organizationId,
    int? streamNameMaxLength,
    int? streamDescriptionMaxLength,
  }) {
    return _dao.updateStreamSettings(
      organizationId: organizationId,
      streamNameMaxLength: streamNameMaxLength,
      streamDescriptionMaxLength: streamDescriptionMaxLength,
    );
  }
}
