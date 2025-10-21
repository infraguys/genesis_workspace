import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/common/usecases/get_version_config_use_case.dart';
import 'package:injectable/injectable.dart';

part 'update_state.dart';

@injectable
class UpdateCubit extends Cubit<UpdateState> {
  UpdateCubit(this._getVersionConfigUseCase) : super(UpdateState());

  final GetVersionConfigUseCase _getVersionConfigUseCase;

  Future<void> getVersionConfig() async {
    try {
      final response = await _getVersionConfigUseCase.call();
      inspect(response);
    } catch (e) {
      inspect(e);
    }
  }
}
