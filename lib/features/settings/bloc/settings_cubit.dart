import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:genesis_workspace/data/database/app_database.dart';
import 'package:genesis_workspace/domain/users/usecases/add_recent_dm_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_recent_dms_use_case.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'settings_state.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(
    this._addRecentDmUseCase,
    this._getRecentDmsUseCase,
    this._appDatabase,
    this._sharedPreferences,
  ) : super(SettingsState());

  final AddRecentDmUseCase _addRecentDmUseCase;
  final GetRecentDmsUseCase _getRecentDmsUseCase;
  final AppDatabase _appDatabase;

  final Dio _dio = Dio();
  final SharedPreferences _sharedPreferences;

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

  Future<void> clearLocalDatabase() async {
    try {
      await _appDatabase.clearAllData();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> clearSharedPreferences() async {
    await _sharedPreferences.clear();
  }
}
