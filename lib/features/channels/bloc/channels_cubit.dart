import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/users/entities/channel_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_subscribed_channels_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_topics_use_case.dart';

part 'channels_state.dart';

class ChannelsCubit extends Cubit<ChannelsState> {
  ChannelsCubit() : super(ChannelsState(channels: [], pendingTopicsId: null));

  final GetSubscribedChannelsUseCase _getSubscribedChannelsUseCase =
      getIt<GetSubscribedChannelsUseCase>();
  final GetTopicsUseCase _getTopicsUseCase = getIt<GetTopicsUseCase>();
  final GetMessagesUseCase _getMessagesUseCase = getIt<GetMessagesUseCase>();

  Future<void> getChannels() async {
    try {
      final response = await _getSubscribedChannelsUseCase.call(true);
      emit(state.copyWith(channels: response.map((e) => e.toChannelEntity()).toList()));
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> getChannelTopics(int streamId) async {
    state.pendingTopicsId = streamId;
    emit(state.copyWith(pendingTopicsId: state.pendingTopicsId));
    try {
      final response = await _getTopicsUseCase.call(streamId);
      state.pendingTopicsId = null;
      state.channels[state.channels.indexWhere((element) => element.streamId == streamId)].topics =
          response;
      emit(state.copyWith(pendingTopicsId: state.pendingTopicsId, channels: state.channels));
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> getChannelMessages(int streamId) async {
    try {
      final response = await _getMessagesUseCase.call(
        MessagesRequestEntity(
          anchor: MessageAnchor.newest(),
          narrow: [
            MessageNarrowEntity(operator: NarrowOperator.channel, operand: [streamId]),
          ],
          numBefore: 25,
          numAfter: 0,
        ),
      );
      inspect(response);
    } catch (e) {
      inspect(e);
    }
  }
}
