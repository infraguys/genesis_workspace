import 'package:drift/drift.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:genesis_workspace/data/organizations/tables/organization_table.dart';
import 'package:injectable/injectable.dart';

part 'organizations_dao.g.dart';

@injectable
@DriftAccessor(tables: [Organizations])
class OrganizationsDao extends DatabaseAccessor<AppDatabase> with _$OrganizationsDaoMixin {
  OrganizationsDao(super.db);

  Future<int> insertOrganization({
    required String name,
    required String icon,
    required String baseUrl,
    required Set<int> unreadMessages,
    String? meetingUrl,
    int? maxStreamNameLength,
    int? maxStreamDescriptionLength,
  }) {
    String refactoredBaseUrl = baseUrl;
    if (baseUrl.endsWith("/")) {
      refactoredBaseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }
    return transaction(() async {
      final existing = await (select(organizations)..where((t) => t.baseUrl.equals(baseUrl))).getSingleOrNull();
      if (existing != null) {
        await (update(organizations)..where((t) => t.id.equals(existing.id))).write(
          OrganizationsCompanion(
            name: Value(name),
            icon: Value(icon),
            baseUrl: Value(refactoredBaseUrl),
            unreadMessages: Value(unreadMessages),
            meetingUrl: meetingUrl != null ? Value(meetingUrl) : const Value.absent(),
            maxStreamNameLength: Value(maxStreamNameLength),
            maxStreamDescriptionLength: Value(maxStreamDescriptionLength),
          ),
        );
        return existing.id;
      }

      return into(organizations).insert(
        OrganizationsCompanion.insert(
          name: name,
          icon: icon,
          baseUrl: refactoredBaseUrl,
          unreadMessages: Value(unreadMessages),
          meetingUrl: Value(meetingUrl),
        ),
        mode: InsertMode.insert,
      );
    });
  }

  Future<int> deleteOrganizationById(int id) {
    return (delete(organizations)..where((t) => t.id.equals(id))).go();
  }

  Future<List<Organization>> getAllOrganizations() {
    return select(organizations).get();
  }

  Stream<List<Organization>> watchAllOrganizations() {
    return select(organizations).watch();
  }

  Future<Organization?> getOrganizationById(int id) {
    return (select(organizations)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<int?> getOrganizationIdByBaseUrl(String baseUrl) async {
    final normalized = _normalizeBaseUrl(baseUrl);
    final org = await (select(organizations)..where((t) => t.baseUrl.equals(normalized))).getSingleOrNull();
    return org?.id;
  }

  Future<int?> getOrganizationIdByComparableUrl(String url) async {
    final String? normalizedTarget = _normalizeUrlForComparison(url);
    if (normalizedTarget == null) return null;

    final List<Organization> allOrganizations = await getAllOrganizations();
    for (final organization in allOrganizations) {
      final String? normalizedOrganizationUrl = _normalizeUrlForComparison(organization.baseUrl);
      if (normalizedOrganizationUrl == normalizedTarget) {
        return organization.id;
      }
    }
    return null;
  }

  Future<void> updateMeetingUrl({
    required int organizationId,
    required String? meetingUrl,
  }) {
    return (update(organizations)..where((t) => t.id.equals(organizationId))).write(
      OrganizationsCompanion(
        meetingUrl: Value(meetingUrl),
      ),
    );
  }

  Future<void> updateStreamSettings({
    required int organizationId,
    int? streamNameMaxLength,
    int? streamDescriptionMaxLength,
  }) {
    return (update(organizations)..where((t) => t.id.equals(organizationId))).write(
      OrganizationsCompanion(
        maxStreamNameLength: Value(streamNameMaxLength),
        maxStreamDescriptionLength: Value(streamDescriptionMaxLength),
      ),
    );
  }

  String _normalizeBaseUrl(String value) {
    if (value.endsWith('/')) {
      return value.substring(0, value.length - 1);
    }
    return value;
  }

  String? _normalizeUrlForComparison(String value) {
    final String trimmed = value.trim();
    if (trimmed.isEmpty) return null;

    Uri? parsed = Uri.tryParse(trimmed);
    if (parsed == null || parsed.host.isEmpty) {
      final String withScheme = trimmed.startsWith('http://') || trimmed.startsWith('https://')
          ? trimmed
          : 'https://$trimmed';
      parsed = Uri.tryParse(withScheme);
    }

    if (parsed == null || parsed.host.isEmpty) {
      return _normalizeBaseUrl(trimmed).toLowerCase();
    }

    final String scheme = parsed.scheme.isEmpty ? 'https' : parsed.scheme.toLowerCase();
    final String host = parsed.host.toLowerCase();
    final int port = parsed.hasPort ? parsed.port : -1;
    final bool isDefaultPort = (scheme == 'http' && port == 80) || (scheme == 'https' && port == 443);
    final String normalizedPort = port > 0 && !isDefaultPort ? ':$port' : '';

    return '$scheme://$host$normalizedPort';
  }
}
