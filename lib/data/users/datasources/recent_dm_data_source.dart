import 'package:genesis_workspace/data/users/dao/recent_dm_dao.dart';
import 'package:injectable/injectable.dart';

@injectable
class RecentDmLocalDataSource {
  final RecentDmDao _dao;
  RecentDmLocalDataSource(this._dao);

  Future<void> add(int directMessageId) async {
    try {
      await _dao.insert(directMessageId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getAll() async {
    try {
      await _dao.getAll();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> remove(int directMessageId) => _dao.deleteById(directMessageId);
  Future<void> replaceAll(Iterable<int> directMessageIds) => _dao.replaceAll(directMessageIds);
}
