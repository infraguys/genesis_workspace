import 'package:bloc/bloc.dart';
import 'package:genesis_workspace/domain/users/usecases/add_recent_dm_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_recent_dms_use_case.dart';
import 'package:injectable/injectable.dart';

part 'settings_state.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._addRecentDmUseCase, this._getRecentDmsUseCase) : super(SettingsState());

  final AddRecentDmUseCase _addRecentDmUseCase;
  final GetRecentDmsUseCase _getRecentDmsUseCase;

  Future<void> addRecentDm(int userId) async {
    try {
      await _addRecentDmUseCase.call(userId);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> getRecentDms() async {
    try {
      await _getRecentDmsUseCase.call();
    } catch (e) {
      rethrow;
    }
  }
}
