import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:genesis_workspace/domain/users/repositories/recent_dm_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetRecentDmsUseCase {
  final RecentDmRepository _repository;

  GetRecentDmsUseCase(this._repository);

  Future<List<RecentDm>> call() async {
    try {
      return await _repository.getRecentDms();
    } catch (e) {
      rethrow;
    }
  }
}
