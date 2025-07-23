import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/domain/users/entities/subscription_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_subscribed_channels_use_case.dart';

part 'channels_state.dart';

class ChannelsCubit extends Cubit<ChannelsState> {
  ChannelsCubit() : super(ChannelsState(channels: []));

  final GetSubscribedChannelsUseCase _getSubscribedChannelsUseCase =
      getIt<GetSubscribedChannelsUseCase>();

  Future<void> getChannels() async {
    try {
      final response = await _getSubscribedChannelsUseCase.call(true);
      emit(state.copyWith(channels: response));
    } catch (e) {
      inspect(e);
    }
  }
}
