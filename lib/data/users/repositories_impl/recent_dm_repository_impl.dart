import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:genesis_workspace/data/users/datasources/recent_dm_data_source.dart';
import 'package:genesis_workspace/domain/users/repositories/recent_dm_repository.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: RecentDmRepository)
class RecentDmRepositoryImpl implements RecentDmRepository {
  final RecentDmLocalDataSource _recentDmLocalDataSource;

  RecentDmRepositoryImpl(this._recentDmLocalDataSource);

  @override
  Future<void> addRecentDm(int userId) async {
    try {
      await _recentDmLocalDataSource.add(userId);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<RecentDm>> getRecentDms() async {
    try {
      return await _recentDmLocalDataSource.getAll();
    } catch (e) {
      rethrow;
    }
  }
}
