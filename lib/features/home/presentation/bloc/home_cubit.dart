import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/domain/users/usecases/get_subscribed_channels_use_case.dart';

part 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit() : super(HomeState());

  final GetSubscribedChannelsUseCase _getSubscribedChannelsUseCase =
      getIt<GetSubscribedChannelsUseCase>();

  Future<void> getSubscribedChannels() async {
    final response = await _getSubscribedChannelsUseCase.call();
    inspect(response);
  }
}
