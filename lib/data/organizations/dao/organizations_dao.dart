import 'package:drift/drift.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:genesis_workspace/data/organizations/tables/organization_table.dart';
import 'package:injectable/injectable.dart';

part 'organizations_dao.g.dart';

@injectable
@DriftAccessor(tables: [Organizations])
class OrganizationsDao extends DatabaseAccessor<AppDatabase> with _$OrganizationsDaoMixin {
  OrganizationsDao(AppDatabase db) : super(db);

  Future<int> insertOrganization({
    required String name,
    required String icon,
    required String baseUrl,
    required Set<int> unreadMessages,
    String? meetingUrl,
  }) {
    return transaction(() async {
      final existing = await (select(organizations)..where((t) => t.baseUrl.equals(baseUrl))).getSingleOrNull();
      if (existing != null) {
        await (update(organizations)..where((t) => t.id.equals(existing.id))).write(
          OrganizationsCompanion(
            name: Value(name),
            icon: Value(icon),
            baseUrl: Value(baseUrl),
            unreadMessages: Value(unreadMessages),
            meetingUrl: meetingUrl != null ? Value(meetingUrl) : const Value.absent(),
          ),
        );
        return existing.id;
      }

      return into(organizations).insert(
        OrganizationsCompanion.insert(
          name: name,
          icon: icon,
          baseUrl: baseUrl,
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
}
