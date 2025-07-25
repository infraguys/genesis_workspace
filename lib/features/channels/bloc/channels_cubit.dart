import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:genesis_workspace/core/dependency_injection/di.dart';
import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/message_type.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_entity.dart';
import 'package:genesis_workspace/domain/users/entities/channel_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_subscribed_channels_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_topics_use_case.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';

part 'channels_state.dart';

class ChannelsCubit extends Cubit<ChannelsState> {
  final _realTimeService = getIt<RealTimeService>();

  ChannelsCubit() : super(ChannelsState(channels: [], pendingTopicsId: null)) {
    _messagesEventsSubscription = _realTimeService.messagesEventsStream.listen(_onMessageEvents);
    _messageFlagsSubscription = _realTimeService.messagesFlagsEventsStream.listen(
      _onMessageFlagsEvents,
    );
  }

  final GetSubscribedChannelsUseCase _getSubscribedChannelsUseCase =
      getIt<GetSubscribedChannelsUseCase>();
  final GetTopicsUseCase _getTopicsUseCase = getIt<GetTopicsUseCase>();
  final GetMessagesUseCase _getMessagesUseCase = getIt<GetMessagesUseCase>();

  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;
  late final StreamSubscription<UpdateMessageFlagsEntity> _messageFlagsSubscription;

  Future<void> getChannels() async {
    try {
      final response = await _getSubscribedChannelsUseCase.call(true);
      final channels = response.map((e) => e.toChannelEntity()).toList();
      emit(state.copyWith(channels: channels));
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> getChannelTopics({
    required int streamId,
    required List<MessageEntity> unreadMessages,
  }) async {
    state.pendingTopicsId = streamId;
    emit(state.copyWith(pendingTopicsId: state.pendingTopicsId));
    try {
      final response = await _getTopicsUseCase.call(streamId);
      state.pendingTopicsId = null;
      final indexOfChannel = state.channels.indexWhere((element) => element.streamId == streamId);
      final channel = state.channels[indexOfChannel];

      channel.topics = response;
      for (var message in unreadMessages) {
        if (message.type == MessageType.stream && message.hasUnreadMessages) {
          final TopicEntity? topic = channel.topics
              .where((topic) => topic.name == message.subject)
              .firstOrNull;
          topic?.unreadMessages.add(message.id);
        }
      }
      emit(state.copyWith(pendingTopicsId: state.pendingTopicsId, channels: state.channels));
    } catch (e) {
      inspect(e);
    }
  }

  void setUnreadMessages(List<MessageEntity> unreadMessages) {
    final channels = [...state.channels];
    for (var message in unreadMessages) {
      if (message.type == MessageType.stream && message.hasUnreadMessages) {
        final channel = channels.firstWhere((channel) => channel.streamId == message.streamId);
        channel.unreadMessages.add(message.id);
      }
    }
    state.channels = channels;
    emit(state.copyWith(channels: state.channels));
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

  void _onMessageEvents(MessageEventEntity event) {
    final message = event.message;
    final channels = state.channels;
    if (message.type == MessageType.stream && message.hasUnreadMessages) {
      final channel = channels.firstWhere((channel) => channel.streamId == message.streamId);
      channel.unreadMessages.add(message.id);

      final TopicEntity? topic = channels
          .firstWhere((channel) => channel.streamId == message.streamId)
          .topics
          .firstWhere((topic) => topic.name == message.subject);
      if (message.subject == topic?.name) {
        topic!.unreadMessages.add(message.id);
      }
    }
    emit(state.copyWith(channels: channels));
  }

  void _onMessageFlagsEvents(UpdateMessageFlagsEntity event) {
    if (event.op == UpdateMessageFlagsOp.add && event.flag == MessageFlag.read) {
      final channels = state.channels.map((channel) {
        channel.unreadMessages.removeAll(event.messages);
        channel.topics.forEach((topic) {
          topic.unreadMessages.removeAll(event.messages);
        });
        return channel;
      }).toList();
      emit(state.copyWith(channels: channels));
    }
  }
}
