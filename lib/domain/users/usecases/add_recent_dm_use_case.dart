import 'package:genesis_workspace/domain/users/repositories/recent_dm_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class AddRecentDmUseCase {
  final RecentDmRepository _repository;

  AddRecentDmUseCase(this._repository);

  Future<void> call(int userId) async {
    try {
      await _repository.addRecentDm(userId);
    } catch (e) {
      rethrow;
    }
  }
}
