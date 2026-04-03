import 'package:genesis_workspace/domain/organizations/entities/organization_entity.dart';
import 'package:genesis_workspace/domain/organizations/entities/server_emoji_list_entity.dart';
import 'package:genesis_workspace/features/authentication/domain/entities/server_settings_entity.dart';

abstract class OrganizationsRepository {
  Future<OrganizationEntity> addOrganization(OrganizationRequestEntity body);

  Future<void> removeOrganization(int id);

  Future<List<OrganizationEntity>> getAllOrganizations();

  Future<OrganizationEntity> getOrganizationById(int id);

  Future<int?> getOrganizationIdByComparableUrl(String url);

  Stream<List<OrganizationEntity>> watchOrganizations();

  Future<ServerSettingsEntity> getOrganizationSettings(String url);

  Future<void> updateMeetingUrl({
    required int organizationId,
    required String? meetingUrl,
  });

  Future<void> updateEmojiServerUrl({
    required int organizationId,
    required String? emojiServerUrl,
  });

  Future<void> updateStreamSettings({required int organizationId, int? maxNameLength, int? maxDescriptionLength});

  Future<ServerEmojiListEntity> getOrganizationEmojiList(String url);
}
