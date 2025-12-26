import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_pinned_chats_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/pin_chat_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/unpin_chat_use_case.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/mark_stream_as_read_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/mark_topic_as_read_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/delete_message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/subscription_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_event_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_topics_use_case.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/services/real_time/multi_polling_service.dart';
import 'package:injectable/injectable.dart';

part 'chats_list_state.dart';

@injectable
class ChatsListCubit extends Cubit<ChatsListState> {
  ChatsListCubit(
    this._getMessagesUseCase,
    this._getTopicsUseCase,
    this._realTimeService,
    this._pinChatUseCase,
    this._unpinChatUseCase,
    this._getPinnedChatsUseCase,
    this._profileCubit,
    this._markStreamAsReadUseCase,
    this._markTopicAsReadUseCase,
  ) : super(
        ChatsListState(
          chats: [],
          isLoadingMessages: false,
          isLoadingMoreMessages: false,
        ),
      ) {
    _messagesEventsSubscription = _realTimeService.messageEventsStream.listen(_onMessageEvents);
    _messageFlagsEventsSubscription = _realTimeService.messageFlagsEventsStream.listen(
      _onMessageFlagsEvents,
    );
    _profileStateSubscription = _profileCubit.stream.listen(_onProfileStateChanged);
    _onProfileStateChanged(_profileCubit.state);
    _subscriptionEventsSubscription = _realTimeService.subscriptionEventsStream.listen(
      _onSubscriptionEvents,
    );
    _deleteMessageEventsSubscription = _realTimeService.deleteMessageEventsStream.listen(_onDeleteEvents);
    _updateMessageEventsSubscription = _realTimeService.updateMessageEventsStream.listen(_onUpdateMessageEvents);
  }

  final GetMessagesUseCase _getMessagesUseCase;
  final GetTopicsUseCase _getTopicsUseCase;
  final PinChatUseCase _pinChatUseCase;
  final UnpinChatUseCase _unpinChatUseCase;
  final GetPinnedChatsUseCase _getPinnedChatsUseCase;
  final MarkStreamAsReadUseCase _markStreamAsReadUseCase;
  final MarkTopicAsReadUseCase _markTopicAsReadUseCase;

  final MultiPollingService _realTimeService;
  final ProfileCubit _profileCubit;

  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;
  late final StreamSubscription<UpdateMessageFlagsEventEntity> _messageFlagsEventsSubscription;
  late final StreamSubscription<ProfileState> _profileStateSubscription;
  late final StreamSubscription<SubscriptionEventEntity> _subscriptionEventsSubscription;
  late final StreamSubscription<DeleteMessageEventEntity> _deleteMessageEventsSubscription;
  late final StreamSubscription<UpdateMessageEventEntity> _updateMessageEventsSubscription;

  String _searchQuery = '';
  int _oldestMessageId = 0;
  int _lastMessageId = -1;
  int _loadingTimes = 0;
  bool _foundOldestMessage = false;
  bool _prioritizePersonalUnread = false;
  bool _prioritizeUnmutedUnreadChannels = false;

  Future<void> getInitialMessages() async {
    emit(state.copyWith(isLoadingMessages: true));
    _loadingTimes = 0;
    try {
      final messagesBody = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        numBefore: 1000,
        numAfter: 0,
        clientGravatar: false,
      );
      final response = await _getMessagesUseCase.call(messagesBody);
      final createdChats = _createChatsFromMessages(response.messages);
      if (response.messages.isNotEmpty) {
        _foundOldestMessage = response.foundOldest;
        _oldestMessageId = response.messages.first.id;
      }
      emit(state.copyWith(chats: createdChats));
      unawaited(lazyLoadMessages());
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    } finally {
      emit(state.copyWith(isLoadingMessages: false));
    }
  }

  Future<void> lazyLoadMessages() async {
    emit(state.copyWith(isLoadingMoreMessages: true));
    try {
      if (_loadingTimes < 5 && !_foundOldestMessage) {
        final body = MessagesRequestEntity(
          anchor: MessageAnchor.id(_oldestMessageId),
          numBefore: 5000,
          numAfter: 0,
          includeAnchor: false,
        );
        final response = await _getMessagesUseCase.call(body);
        if (response.messages.isNotEmpty) {
          _foundOldestMessage = response.foundOldest;
          _oldestMessageId = response.messages.first.id;
          final chats = _createChatsFromMessages(response.messages);
          final updatedChats = <ChatEntity>[...state.chats, ...chats];
          emit(state.copyWith(chats: updatedChats));
        }
        await lazyLoadMessages();
      }
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    } finally {
      emit(state.copyWith(isLoadingMoreMessages: false));
    }
  }

  List<ChatEntity> _createChatsFromMessages(List<MessageEntity> messages) {
    final createdChats = <ChatEntity>[];
    messages.forEach((message) {
      final isMyMessage = message.senderId == state.selfUser?.userId;
      if (createdChats.any((chat) => chat.id == message.recipientId)) {
        final chat = createdChats.firstWhere((chat) => chat.id == message.recipientId);
        final indexOfChat = createdChats.indexOf(chat);
        final updatedChat = chat.copyWith(
          lastMessageId: message.id,
          lastMessagePreview: message.content,
          lastMessageDate: message.messageDate,
          displayTitle: !isMyMessage ? message.displayTitle : null,
          lastMessageSenderName: !isMyMessage ? message.displayTitle : null,
          avatarUrl: !isMyMessage ? message.avatarUrl : null,
          unreadMessages: message.isUnread ? {...chat.unreadMessages, message.id} : chat.unreadMessages,
        );
        createdChats[indexOfChat] = updatedChat;
      } else {
        final chat = ChatEntity.createChatFromMessage(
          message,
          isMyMessage: isMyMessage,
        );
        createdChats.add(chat);
      }
    });
    return createdChats;
  }

  void _onProfileStateChanged(ProfileState profileState) {
    final user = profileState.user;
    if (user == null) return;
    if (state.selfUser?.userId == user.userId) return;
    emit(state.copyWith(selfUser: user));
  }

  void _onMessageEvents(MessageEventEntity event) {}
  void _onMessageFlagsEvents(UpdateMessageFlagsEventEntity event) {}
  void _onSubscriptionEvents(SubscriptionEventEntity event) {}
  void _onDeleteEvents(DeleteMessageEventEntity event) {}
  void _onUpdateMessageEvents(UpdateMessageEventEntity event) {}
}
