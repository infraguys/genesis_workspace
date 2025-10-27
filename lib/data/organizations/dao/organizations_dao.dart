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
  }) {
    return into(organizations).insertOnConflictUpdate(
      OrganizationsCompanion.insert(name: name, icon: icon, baseUrl: baseUrl),
    );
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
}
