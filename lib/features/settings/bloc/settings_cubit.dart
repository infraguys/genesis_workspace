import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:genesis_workspace/domain/users/usecases/add_recent_dm_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_recent_dms_use_case.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<void> createHelloWorldFile() async {
    try {
      // Получаем директорию приложения (application documents directory)
      final appDir = await getApplicationDocumentsDirectory();

      // Создаем путь к файлу hello.txt в корне директории приложения
      final File file = File('${appDir.path}/hello.txt');

      // Записываем текст в файл
      await file.writeAsString('Hello world!');

      print('Файл успешно создан: ${file.path}');
    } catch (error, stackTrace) {
      print('Ошибка при создании файла: $error');
      print(stackTrace);
    }
  }

  Future<void> deleteHelloWorldFile() async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final File file = File('${appDir.path}/hello.txt');

      if (await file.exists()) {
        await file.delete();
        print('Файл успешно удалён: ${file.path}');
      } else {
        print('Файл не найден: ${file.path}');
      }
    } catch (error, stackTrace) {
      print('Ошибка при удалении файла: $error');
      print(stackTrace);
    }
  }
}
