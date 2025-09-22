import 'dart:async';
import 'dart:developer';

import 'package:bloc/bloc.dart';
import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/message_type.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/delete_message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_event_entity.dart';
import 'package:genesis_workspace/domain/users/entities/channel_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_subscribed_channels_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_topics_use_case.dart';
import 'package:genesis_workspace/services/real_time/real_time_service.dart';
import 'package:injectable/injectable.dart';

part 'channels_state.dart';

@injectable
class ChannelsCubit extends Cubit<ChannelsState> {
  final RealTimeService _realTimeService;

  ChannelsCubit(
    this._realTimeService,
    this._getTopicsUseCase,
    this._getMessagesUseCase,
    this._getSubscribedChannelsUseCase,
  ) : super(
        ChannelsState(
          channels: [],
          pendingTopicsId: null,
          selectedChannelId: null,
          selectedTopic: null,
          unreadMessages: [],
          selfUser: null,
          selectedChannel: null,
        ),
      ) {
    _messagesEventsSubscription = _realTimeService.messagesEventsStream.listen(_onMessageEvents);
    _messageFlagsSubscription = _realTimeService.messagesFlagsEventsStream.listen(
      _onMessageFlagsEvents,
    );
    _deleteMessageEventsSubscription = _realTimeService.deleteMessageEventsStream.listen(
      _onDeleteMessageEvents,
    );
  }

  final GetSubscribedChannelsUseCase _getSubscribedChannelsUseCase;
  final GetTopicsUseCase _getTopicsUseCase;
  final GetMessagesUseCase _getMessagesUseCase;

  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;
  late final StreamSubscription<UpdateMessageFlagsEventEntity> _messageFlagsSubscription;
  late final StreamSubscription<DeleteMessageEventEntity> _deleteMessageEventsSubscription;

  Future<void> getUnreadMessages() async {
    try {
      final messagesBody = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        narrow: [MessageNarrowEntity(operator: NarrowOperator.isFilter, operand: 'unread')],
        numBefore: 5000,
        numAfter: 0,
      );
      final response = await _getMessagesUseCase.call(messagesBody);
      final unreadMessages = response.messages;
      final channels = [...state.channels];
      for (var channel in channels) {
        channel.unreadMessages = unreadMessages
            .where((message) {
              return (message.streamId == channel.streamId) &&
                  (message.type == MessageType.stream) &&
                  (message.senderId != state.selfUser?.userId);
            })
            .map((message) => message.id)
            .toSet();
      }
      state.channels = channels;
      emit(state.copyWith(unreadMessages: unreadMessages, channels: channels));
    } catch (e) {
      inspect(e);
    }
  }

  void selectChannelId(ChannelEntity channel) {
    emit(state.copyWith(selectedChannelId: channel.streamId, selectedChannel: channel));
  }

  void closeChannel() {
    state.selectedChannel = null;
    state.selectedChannelId = null;
    state.selectedTopic = null;
    emit(
      state.copyWith(
        selectedChannel: state.selectedChannel,
        selectedChannelId: state.selectedChannelId,
        selectedTopic: state.selectedTopic,
      ),
    );
  }

  void openTopic({required ChannelEntity channel, TopicEntity? topic}) {
    state.selectedChannel = channel;
    state.selectedTopic = topic;
    emit(
      state.copyWith(selectedChannel: state.selectedChannel, selectedTopic: state.selectedTopic),
    );
  }

  setSelfUser(UserEntity? user) {
    if (state.selfUser == null) {
      state.selfUser = user;
      emit(state.copyWith(selfUser: state.selfUser));
    }
  }

  Future<void> getChannels({int? initialChannelId, String? initialTopicName}) async {
    try {
      final response = await _getSubscribedChannelsUseCase.call(true);
      emit(state.copyWith(channels: response.map((e) => e.toChannelEntity()).toList()));
      if (initialChannelId != null) {
        emit(state.copyWith(selectedChannelId: initialChannelId));
        final indexOfChannel = state.channels.indexWhere(
          (element) => element.streamId == initialChannelId,
        );
        final selectedChannel = state.channels[indexOfChannel];
        await getChannelTopics(streamId: initialChannelId);
        if (initialTopicName != null) {
          final topicName = initialTopicName.replaceAll('-', ' ');
          final indexOfTopic = state.channels[indexOfChannel].topics.indexWhere(
            (element) => element.name.toLowerCase() == topicName.toLowerCase(),
          );
          final selectedTopic = selectedChannel.topics[indexOfTopic];
          emit(state.copyWith(selectedTopic: selectedTopic));
        }
        emit(state.copyWith(selectedChannel: selectedChannel));
      }
    } catch (e) {
      inspect(e);
    }
    await getUnreadMessages();
  }

  Future<void> getChannelTopics({required int streamId}) async {
    state.pendingTopicsId = streamId;
    emit(state.copyWith(pendingTopicsId: state.pendingTopicsId));
    try {
      final response = await _getTopicsUseCase.call(streamId);
      state.pendingTopicsId = null;
      final indexOfChannel = state.channels.indexWhere((element) => element.streamId == streamId);
      final channel = state.channels[indexOfChannel];

      channel.topics = response;
      for (var message in state.unreadMessages) {
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

  void _onMessageEvents(MessageEventEntity event) {
    final message = event.message;
    if (message.senderId == state.selfUser!.userId) {
      return;
    }
    final channels = [...state.channels];
    final unreadMessages = [...state.unreadMessages];
    if (message.type == MessageType.stream && message.hasUnreadMessages) {
      unreadMessages.add(message);
      final channel = channels.firstWhere((channel) => channel.streamId == message.streamId);
      final indexOfChannel = channels.indexOf(channel);
      channel.unreadMessages.add(message.id);
      channels[indexOfChannel] = channel;
      if (channel.topics.isNotEmpty) {
        final TopicEntity topic = channel.topics.firstWhere(
          (topic) => topic.name == message.subject,
        );
        if (message.subject == topic.name) {
          topic.unreadMessages.add(message.id);
        }
      }
    }
    emit(state.copyWith(channels: channels, unreadMessages: unreadMessages));
  }

  void _onMessageFlagsEvents(UpdateMessageFlagsEventEntity event) {
    final unreadMessages = [...state.unreadMessages];
    if (event.op == UpdateMessageFlagsOp.add && event.flag == MessageFlag.read) {
      unreadMessages.removeWhere((message) => event.messages.contains(message.id));
      final channels = state.channels.map((channel) {
        channel.unreadMessages.removeAll(event.messages);
        for (var topic in channel.topics) {
          topic.unreadMessages.removeAll(event.messages);
        }
        return channel;
      }).toList();
      emit(state.copyWith(channels: channels, unreadMessages: unreadMessages));
    }
  }

  void _onDeleteMessageEvents(DeleteMessageEventEntity event) {
    final updatedChannels = [...state.channels];
    final channel = updatedChannels.firstWhere((channel) => channel.streamId == event.streamId);
    final indexOfChannel = updatedChannels.indexOf(channel);
    channel.unreadMessages.remove(event.messageId);
    updatedChannels[indexOfChannel] = channel;
    final topic = updatedChannels[indexOfChannel].topics.firstWhere(
      (topic) => topic.name == event.topic,
    );
    topic.unreadMessages.remove(event.messageId);
    emit(state.copyWith(channels: updatedChannels));
  }

  @override
  Future<void> close() {
    _messagesEventsSubscription.cancel();
    _messageFlagsSubscription.cancel();
    _deleteMessageEventsSubscription.cancel();
    return super.close();
  }
}
