import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:genesis_workspace/domain/genesis/entities/genesis_service_entity.dart';
import 'package:genesis_workspace/domain/genesis/usecases/get_services_use_case.dart';
import 'package:injectable/injectable.dart';

part 'genesis_services_state.dart';

@injectable
class GenesisServicesCubit extends Cubit<GenesisServicesState> {
  GenesisServicesCubit(this._getServicesUseCase) : super(GenesisServicesInitial());

  final GetServicesUseCase _getServicesUseCase;

  Future<void> loadServices() async {
    emit(GenesisServicesLoading());
    try {
      await Future.delayed(const Duration(seconds: 5));
      final response = await _getServicesUseCase.call();
      emit(GenesisServicesLoaded(services: response));
    } catch (e) {
      emit(GenesisServicesError());
      if (kDebugMode) {
        inspect(e);
      }
    }
  }
}
