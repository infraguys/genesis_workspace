import 'package:genesis_workspace/data/database/app_database.dart';

abstract class RecentDmRepository {
  Future<void> addRecentDm(int userId);
  Future<List<RecentDm>> getRecentDms();
}
