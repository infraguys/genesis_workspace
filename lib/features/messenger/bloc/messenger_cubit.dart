import 'dart:async';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/enums/chat_type.dart';
import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/subscription_op.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/data/users/dto/update_subscription_settings_dto.dart';
import 'package:genesis_workspace/domain/all_chats/entities/pinned_chat_entity.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/add_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/delete_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_folder_ids_for_chat_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_folders_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_members_for_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_pinned_chats_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/pin_chat_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/remove_all_memberships_for_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/set_folders_for_chat_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/unpin_chat_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/update_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/update_pinned_chat_order_use_case.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/subscription_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_event_entity.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:genesis_workspace/domain/users/entities/subscription_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/domain/users/entities/update_subscription_settings_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_subscribed_channels_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/get_topics_use_case.dart';
import 'package:genesis_workspace/domain/users/usecases/update_subscription_settings_use_case.dart';
import 'package:genesis_workspace/features/profile/bloc/profile_cubit.dart';
import 'package:genesis_workspace/services/real_time/multi_polling_service.dart';
import 'package:injectable/injectable.dart';

part 'messenger_state.dart';

@injectable
class MessengerCubit extends Cubit<MessengerState> {
  final AddFolderUseCase _addFolderUseCase;
  final GetFoldersUseCase _getFoldersUseCase;
  final UpdateFolderUseCase _updateFolderUseCase;
  final DeleteFolderUseCase _deleteFolderUseCase;
  final RemoveAllMembershipsForFolderUseCase _removeAllMembershipsForFolderUseCase;
  final GetMembersForFolderUseCase _getMembersForFolderUseCase;
  final GetMessagesUseCase _getMessagesUseCase;
  final GetTopicsUseCase _getTopicsUseCase;
  final PinChatUseCase _pinChatUseCase;
  final UnpinChatUseCase _unpinChatUseCase;
  final GetPinnedChatsUseCase _getPinnedChatsUseCase;
  final SetFoldersForChatUseCase _setFoldersForChatUseCase;
  final GetFolderIdsForChatUseCase _getFolderIdsForChatUseCase;
  final UpdatePinnedChatOrderUseCase _updatePinnedChatOrderUseCase;
  final GetSubscribedChannelsUseCase _getSubscribedChannelsUseCase;
  final UpdateSubscriptionSettingsUseCase _updateSubscriptionSettingsUseCase;

  final MultiPollingService _realTimeService;
  final ProfileCubit _profileCubit;

  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;
  late final StreamSubscription<UpdateMessageFlagsEventEntity> _messageFlagsEventsSubscription;
  late final StreamSubscription<ProfileState> _profileStateSubscription;
  late final StreamSubscription<SubscriptionEventEntity> _subscriptionEventsSubscription;
  String _searchQuery = '';
  int _lastMessageId = 0;
  int _loadingTimes = 0;

  MessengerCubit(
    this._addFolderUseCase,
    this._getFoldersUseCase,
    this._updateFolderUseCase,
    this._deleteFolderUseCase,
    this._removeAllMembershipsForFolderUseCase,
    this._getMembersForFolderUseCase,
    this._getMessagesUseCase,
    this._getTopicsUseCase,
    this._realTimeService,
    this._pinChatUseCase,
    this._unpinChatUseCase,
    this._getPinnedChatsUseCase,
    this._setFoldersForChatUseCase,
    this._getFolderIdsForChatUseCase,
    this._updatePinnedChatOrderUseCase,
    this._profileCubit,
    this._getSubscribedChannelsUseCase,
    this._updateSubscriptionSettingsUseCase,
  ) : super(
        MessengerState(
          selfUser: null,
          folders: [],
          selectedFolderIndex: 0,
          messages: [],
          unreadMessages: [],
          chats: [],
          selectedChat: null,
          pinnedChats: [],
          filteredChatIds: null,
          filteredChats: null,
          foundOldestMessage: false,
          subscribedChannels: [],
        ),
      ) {
    _messagesEventsSubscription = _realTimeService.messageEventsStream.listen(_onMessageEvents);
    _messageFlagsEventsSubscription = _realTimeService.messageFlagsEventsStream.listen(
      _onMessageFlagsEvents,
    );
    _profileStateSubscription = _profileCubit.stream.listen(_onProfileStateChanged);
    _subscriptionEventsSubscription = _realTimeService.subscriptionEventsStream.listen(
      _onSubscriptionEvents,
    );
  }

  void _onProfileStateChanged(ProfileState profileState) {
    final user = profileState.user;
    if (user == null) return;
    if (state.selfUser?.userId == user.userId) return;
    emit(state.copyWith(selfUser: user));
  }

  void _createChatsFromMessages(List<MessageEntity> messages) {
    final chats = [...state.chats];
    final unreadMessages = [...state.unreadMessages];
    for (var message in messages.reversed) {
      final recipientId = message.recipientId;
      final isMyMessage = message.isMyMessage(state.selfUser?.userId);
      final bool isChatExist = chats.any((chat) => chat.id == message.recipientId);
      if (message.isUnread) {
        unreadMessages.add(message);
      }
      if (isChatExist) {
        ChatEntity chat = chats.firstWhere((chat) => chat.id == recipientId);
        final indexOfChat = chats.indexOf(chat);
        chat = chat.updateLastMessage(message, isMyMessage: isMyMessage);
        chats[indexOfChat] = chat;
      } else {
        ChatEntity chat = ChatEntity.createChatFromMessage(
          message.copyWith(avatarUrl: isMyMessage ? null : message.avatarUrl),
          isMyMessage: isMyMessage,
        );
        if (chat.type == ChatType.channel) {
          final subscription = state.subscribedChannels.firstWhere(
            (subscription) => subscription.streamId == chat.streamId,
            orElse: SubscriptionEntity.fake,
          );
          if (subscription.isMuted) {
            chat = chat.copyWith(isMuted: true);
          }
        }
        chats.add(chat);
      }
    }
    emit(state.copyWith(chats: chats, unreadMessages: unreadMessages));
  }

  void getUser() {
    final user = _profileCubit.state.user;
    if (state.selfUser == null) {
      emit(state.copyWith(selfUser: user));
    }
  }

  Future<void> getInitialMessages() async {
    _loadingTimes = 0;
    try {
      final messagesBody = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        numBefore: 1000,
        numAfter: 0,
        clientGravatar: false,
      );
      final response = await _getMessagesUseCase.call(messagesBody);
      final channelsResponse = await _getSubscribedChannelsUseCase.call(false);
      _lastMessageId = response.messages.first.id;
      final messages = response.messages;
      final foundOldest = response.foundOldest;
      emit(
        state.copyWith(
          messages: messages,
          foundOldestMessage: foundOldest,
          subscribedChannels: channelsResponse,
        ),
      );
      _createChatsFromMessages(messages);
      await getPinnedChats();
      _sortChats();
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }

  Future<void> lazyLoadAllMessages() async {
    if (!state.foundOldestMessage && _loadingTimes < 6) {
      try {
        final body = MessagesRequestEntity(
          anchor: MessageAnchor.id(_lastMessageId),
          numBefore: 5000,
          numAfter: 0,
          includeAnchor: false,
        );
        final response = await _getMessagesUseCase.call(body);
        _lastMessageId = response.messages.first.id;
        final foundOldest = response.foundOldest;
        final messages = [...state.messages];
        messages.addAll(response.messages);
        emit(
          state.copyWith(
            messages: messages,
            foundOldestMessage: _loadingTimes == 5 ? true : foundOldest,
          ),
        );
        _createChatsFromMessages(response.messages);
        await getPinnedChats();
        _sortChats();
        _loadingTimes += 1;
        await lazyLoadAllMessages();
      } catch (e) {
        if (kDebugMode) {
          inspect(e);
        }
      }
    }
  }

  Future<void> getUnreadMessages() async {
    final organizationId = AppConstants.selectedOrganizationId;
    final connection = _realTimeService.activeConnections[organizationId];
    if (connection?.isActive ?? false) return;
    try {
      final messagesBody = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        narrow: [MessageNarrowEntity(operator: NarrowOperator.isFilter, operand: 'unread')],
        numBefore: 5000,
        numAfter: 0,
      );
      final response = await _getMessagesUseCase.call(messagesBody);
      if (response.messages.isEmpty) {
        List<ChatEntity> updatedChats = [...state.chats];
        for (var chat in updatedChats) {
          chat.unreadMessages.clear();
        }
        emit(state.copyWith(chats: updatedChats));
        return;
      }
      final updatedMessages = response.messages.isEmpty ? <MessageEntity>[] : [...state.unreadMessages];
      updatedMessages.addAll(response.messages);
      emit(state.copyWith(unreadMessages: updatedMessages));
      _createChatsFromMessages(response.messages);
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> getPinnedChats() async {
    final organizationId = AppConstants.selectedOrganizationId!;
    final response = await _getPinnedChatsUseCase.call(
      folderId: state.folders[state.selectedFolderIndex].id!,
      organizationId: organizationId,
    );
    final updatedChats = [...state.chats];
    for (var pinnedChat in response) {
      if (updatedChats.any(
        (chat) => chat.id == pinnedChat.chatId && state.folders[state.selectedFolderIndex].id == pinnedChat.folderId,
      )) {
        final chat = updatedChats.firstWhere((chat) => chat.id == pinnedChat.chatId);
        final indexOfChat = updatedChats.indexOf(chat);
        final updatedChat = chat.copyWith(isPinned: true);
        updatedChats[indexOfChat] = updatedChat;
      }
    }
    emit(state.copyWith(pinnedChats: response, chats: updatedChats));
  }

  Future<void> muteChannel(ChatEntity chat) async {
    if (chat.type != ChatType.channel || chat.streamId == null) {
      return;
    }
    try {
      final UpdateSubscriptionRequestEntity body = UpdateSubscriptionRequestEntity(
        updates: [SubscriptionUpdateEntity(streamId: chat.streamId!, isMuted: true)],
      );
      await _updateSubscriptionSettingsUseCase.call(body);
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }

  Future<void> unmuteChannel(ChatEntity chat) async {
    if (chat.type != ChatType.channel || chat.streamId == null) {
      return;
    }
    try {
      final UpdateSubscriptionRequestEntity body = UpdateSubscriptionRequestEntity(
        updates: [SubscriptionUpdateEntity(streamId: chat.streamId!, isMuted: false)],
      );
      await _updateSubscriptionSettingsUseCase.call(body);
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }

  void selectChat(ChatEntity chat, {String? selectedTopic}) {
    if (selectedTopic == null) {
      state.selectedTopic = null;
    } else {
      state.selectedTopic = selectedTopic;
    }
    emit(state.copyWith(selectedChat: chat, selectedTopic: state.selectedTopic));
  }

  Future<void> loadFolders() async {
    try {
      final int? organizationId = AppConstants.selectedOrganizationId;
      if (organizationId == null) {
        return;
      }

      final List<FolderItemEntity> dbFolders = await _getFoldersUseCase.call(organizationId);
      if (dbFolders.isEmpty) {
        final initFolder = FolderItemEntity(
          title: 'All',
          systemType: SystemFolderType.all,
          iconData: Icons.markunread,
          unreadMessages: const <int>{},
          pinnedChats: [],
          organizationId: organizationId,
        );
        await addFolder(initFolder);
        return;
      }
      final List<FolderItemEntity> initialFolders = [...dbFolders];
      emit(state.copyWith(folders: initialFolders, selectedFolderIndex: 0));
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> addFolder(FolderItemEntity folder) async {
    try {
      await _addFolderUseCase.call(folder);
      final updatedFolders = [...state.folders];
      updatedFolders.add(folder.copyWith(id: updatedFolders.length));
      emit(state.copyWith(folders: updatedFolders));
    } catch (e) {
      inspect(e);
    }
  }

  void selectFolder(int newIndex) async {
    if (state.selectedFolderIndex == newIndex) return;
    emit(state.copyWith(selectedFolderIndex: newIndex));
    _filterChatsByFolder();
    await getPinnedChats();
    _sortChats();
  }

  void searchChats(String query) {
    _searchQuery = query.trim();
    _applySearchFilter();
  }

  Future<void> setFoldersForChat(List<int> foldersIds, int chatId) async {
    try {
      final int? organizationId = AppConstants.selectedOrganizationId;
      if (organizationId == null) return;

      await _setFoldersForChatUseCase.call(
        chatId,
        foldersIds,
        organizationId: organizationId,
      );
      _filterChatsByFolder();
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> updateFolder(FolderItemEntity folder) async {
    if (folder.systemType != null || folder.id == null) return;
    final updatedFolders = [...state.folders];
    final index = updatedFolders.indexWhere((element) => element.id == folder.id);
    await _updateFolderUseCase.call(folder);
    updatedFolders[index] = folder;
    emit(state.copyWith(folders: updatedFolders));
  }

  Future<void> deleteFolder(FolderItemEntity folder) async {
    if (folder.id == 0) return;
    if (folder.systemType != null || folder.id == null) return;
    final int? organizationId = AppConstants.selectedOrganizationId;
    if (organizationId == null) return;
    final updatedFolders = [...state.folders];
    final index = updatedFolders.indexWhere((element) => element.id == folder.id);
    await _removeAllMembershipsForFolderUseCase.call(folder.id!, organizationId: organizationId);
    await _deleteFolderUseCase.call(folder.id!);
    updatedFolders.removeAt(index);
    emit(
      state.copyWith(
        folders: updatedFolders,
        selectedFolderIndex: 0,
      ),
    );
    _filterChatsByFolder();
  }

  Future<List<int>> getFolderIdsForChat(int chatId) async {
    final int? organizationId = AppConstants.selectedOrganizationId;
    if (organizationId == null) return [];
    final response = await _getFolderIdsForChatUseCase.call(chatId, organizationId: organizationId);
    return response;
  }

  Future<void> getChannelTopics(int streamId) async {
    try {
      final topics = await _getTopicsUseCase.call(streamId);
      for (TopicEntity topic in topics) {
        final lastMessageId = topic.maxId;
        final indexOfTopic = topics.indexOf(topic);
        final message = state.messages.firstWhere(
          (message) => message.id == lastMessageId,
          orElse: () => MessageEntity.fake(content: 'Last message not found...'),
        );
        final updatedTopic = topic.copyWith(
          lastMessageSenderName: message.senderFullName,
          lastMessagePreview: message.content,
        );
        topics[indexOfTopic] = updatedTopic;
      }

      for (final message in state.unreadMessages) {
        if (message.streamId == streamId) {
          TopicEntity topic = topics.firstWhere((topic) => topic.name == message.subject);
          final indexOfTopic = topics.indexOf(topic);
          topic = topic.copyWith(unreadMessages: {...topic.unreadMessages, message.id});
          topics[indexOfTopic] = topic;
        }
      }

      List<ChatEntity> updatedChats = [...state.chats];
      ChatEntity chat = updatedChats.firstWhere((chat) => chat.streamId == streamId);
      int indexOfChat = updatedChats.indexOf(chat);
      chat = chat.copyWith(topics: topics);
      updatedChats[indexOfChat] = chat;
      emit(state.copyWith(chats: updatedChats));
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> loadTopics(int streamId) async {
    final chat = state.chats.firstWhere((chat) => chat.streamId == streamId);
    emit(state.copyWith(selectedChat: chat));
    await getChannelTopics(streamId);
    final updatedChat = state.chats.firstWhere((chat) => chat.streamId == streamId);
    emit(state.copyWith(selectedChat: updatedChat));
  }

  Future<void> pinChat({required int chatId}) async {
    try {
      final int? organizationId = AppConstants.selectedOrganizationId;
      if (organizationId == null) return;

      final int folderId = state.folders[state.selectedFolderIndex].id!;
      List<FolderItemEntity> updatedFolders = [...state.folders];
      FolderItemEntity folder = updatedFolders.firstWhere((folder) => folder.id == folderId);
      await _pinChatUseCase.call(
        folderId: folderId,
        chatId: chatId,
        orderIndex: folder.pinnedChats.length,
        organizationId: organizationId,
      );
      final int indexOfFolder = updatedFolders.indexOf(folder);
      final pinnedChats = await _getPinnedChatsUseCase.call(
        folderId: folderId,
        organizationId: organizationId,
      );
      folder = folder.copyWith(pinnedChats: pinnedChats);
      updatedFolders[indexOfFolder] = folder;
      emit(state.copyWith(folders: updatedFolders, pinnedChats: pinnedChats));
      _sortChats();
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> unpinChat(int chatId) async {
    try {
      final int? organizationId = AppConstants.selectedOrganizationId;
      if (organizationId == null) return;

      final int folderId = state.folders[state.selectedFolderIndex].id!;
      final int pinnedChatId = state.pinnedChats.firstWhere((pinnedChat) => pinnedChat.chatId == chatId).id;
      await _unpinChatUseCase.call(pinnedChatId);
      List<FolderItemEntity> updatedFolders = [...state.folders];
      FolderItemEntity folder = updatedFolders.firstWhere((folder) => folder.id == folderId);
      final int indexOfFolder = updatedFolders.indexOf(folder);
      final pinnedChats = await _getPinnedChatsUseCase.call(
        folderId: folderId,
        organizationId: organizationId,
      );
      folder = folder.copyWith(pinnedChats: pinnedChats);
      updatedFolders[indexOfFolder] = folder;
      emit(state.copyWith(folders: updatedFolders, pinnedChats: pinnedChats));
      _sortChats();
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> reorderPinnedChats({
    required int folderId,
    required int movedChatId,
    int? previousChatId,
    int? nextChatId,
  }) async {
    try {
      final int? organizationId = AppConstants.selectedOrganizationId;
      if (organizationId == null) return;
      await _updatePinnedChatOrderUseCase.call(
        folderId: folderId,
        movedChatId: movedChatId,
        previousChatId: previousChatId,
        nextChatId: nextChatId,
        organizationId: organizationId,
      );

      // перезагрузим пины для этой папки и переиздадим state
      final List<PinnedChatEntity> refreshedPins = await _getPinnedChatsUseCase.call(
        folderId: folderId,
        organizationId: organizationId,
      );

      final List<FolderItemEntity> updatedFolders = [...state.folders];
      final int folderIndex = updatedFolders.indexWhere((f) => f.id == folderId);
      if (folderIndex != -1) {
        final FolderItemEntity updatedFolder = updatedFolders[folderIndex].copyWith(
          pinnedChats: refreshedPins,
        );
        updatedFolders[folderIndex] = updatedFolder;
        emit(state.copyWith(folders: updatedFolders, pinnedChats: refreshedPins));
        _sortChats();
      }
    } catch (e, s) {
      // обработка/логирование
    }
  }

  void resetState() {
    _searchQuery = '';
    emit(
      state.copyWith(
        folders: [],
        selectedFolderIndex: 0,
        messages: [],
        chats: [],
        filteredChatIds: null,
        filteredChats: null,
      ),
    );
  }

  void _onMessageEvents(MessageEventEntity event) {
    final int? organizationId = AppConstants.selectedOrganizationId;
    if (organizationId != event.organizationId) return;
    final message = event.message;

    final chatId = message.recipientId;
    final isMyMessage = message.isMyMessage(state.selfUser?.userId);

    final updatedMessages = [...state.messages, message];
    final updatedUnreadMessages = [...state.unreadMessages];
    List<ChatEntity> updatedChats = [...state.chats];

    if (state.chats.any((chat) => chat.id == chatId)) {
      final chat = state.chats.firstWhere((chat) => chat.id == chatId);
      final indexOfChat = state.chats.indexOf(chat);
      ChatEntity updatedChat = chat;
      final messageSenderName = message.senderFullName;
      final messagePreview = message.content;
      final messageDate = message.messageDate;

      updatedChat = updatedChat.copyWith(
        lastMessageId: message.id,
        lastMessageSenderName: messageSenderName,
        lastMessagePreview: messagePreview,
        lastMessageDate: messageDate,
      );
      if (message.isUnread && !isMyMessage) {
        updatedUnreadMessages.add(message);
        //if message is unread and send in topic
        if (updatedChat.topics?.any((topic) => topic.name == message.subject) ?? false) {
          final topic = updatedChat.topics!.firstWhere((topic) => topic.name == message.subject);
          final indexOfTopic = updatedChat.topics!.indexOf(topic);
          updatedChat.topics![indexOfTopic].unreadMessages.add(message.id);
          final updatedTopic = updatedChat.topics![indexOfTopic].copyWith(
            lastMessageSenderName: messageSenderName,
            lastMessagePreview: messagePreview,
          );
          updatedChat.topics![indexOfTopic] = updatedTopic;
        }
        updatedChat = updatedChat.copyWith(
          unreadMessages: {...updatedChat.unreadMessages, message.id},
        );
      }
      updatedChats[indexOfChat] = updatedChat;
    } else {
      final chat = ChatEntity.createChatFromMessage(
        message.copyWith(avatarUrl: isMyMessage ? null : message.avatarUrl),
        isMyMessage: isMyMessage,
      );
      updatedChats.add(chat);
    }
    emit(state.copyWith(messages: updatedMessages, chats: updatedChats, unreadMessages: updatedUnreadMessages));
    _sortChats();
  }

  void _onMessageFlagsEvents(UpdateMessageFlagsEventEntity event) {
    final int? organizationId = AppConstants.selectedOrganizationId;
    if (organizationId != event.organizationId) return;
    List<ChatEntity> updatedChats = [...state.chats];
    List<MessageEntity> updatedUnreadMessages = [...state.unreadMessages];
    if (event.op == UpdateMessageFlagsOp.add && event.flag == MessageFlag.read) {
      for (final messageId in event.messages) {
        updatedUnreadMessages.removeWhere((message) => message.id == messageId);
        final message = state.unreadMessages.firstWhere((message) => message.id == messageId);
        ChatEntity updatedChat = updatedChats.firstWhere((chat) => chat.id == message.recipientId);
        final indexOfChat = state.chats.indexOf(updatedChat);
        updatedChat.unreadMessages.remove(messageId);
        updatedChat.topics?.forEach((topic) {
          topic.unreadMessages.remove(messageId);
        });
        updatedChats[indexOfChat] = updatedChat;
      }
    }
    emit(state.copyWith(chats: updatedChats, unreadMessages: updatedUnreadMessages));
  }

  void _onSubscriptionEvents(SubscriptionEventEntity event) {
    if (event.op == SubscriptionOp.update && event.property == SubscriptionProperty.isMuted) {
      List<ChatEntity> updatedChats = [...state.chats];
      ChatEntity chat = updatedChats.firstWhere((chat) => chat.streamId == event.streamId);
      final indexOfChat = updatedChats.indexOf(chat);
      chat = chat.copyWith(isMuted: event.value.raw == true ? true : false);
      updatedChats[indexOfChat] = chat;
      emit(state.copyWith(chats: updatedChats));
      _sortChats();
    }
  }

  @override
  Future<void> close() {
    _messagesEventsSubscription.cancel();
    _messageFlagsEventsSubscription.cancel();
    _profileStateSubscription.cancel();
    _subscriptionEventsSubscription.cancel();
    return super.close();
  }

  Future<void> _filterChatsByFolder() async {
    Set<int>? filteredIds;
    final int? organizationId = AppConstants.selectedOrganizationId;

    if (state.folders.isNotEmpty && state.selectedFolderIndex > 0 && state.selectedFolderIndex < state.folders.length) {
      final folder = state.folders[state.selectedFolderIndex];
      final int? folderId = folder.id;

      if (folderId != null && organizationId != null) {
        try {
          final members = await _getMembersForFolderUseCase.call(
            folderId,
            organizationId: organizationId,
          );
          filteredIds = members.chatIds.toSet();
        } catch (e) {
          inspect(e);
        }
      }
    }

    state.filteredChatIds = filteredIds;

    emit(state.copyWith(filteredChatIds: state.filteredChatIds));
    _applySearchFilter();
  }

  List<ChatEntity> _chatsForCurrentFolder() {
    if (state.filteredChatIds == null) {
      return state.chats;
    }
    return state.chats.where((chat) => state.filteredChatIds!.contains(chat.id)).toList();
  }

  void _applySearchFilter() {
    final String query = _searchQuery.trim();
    if (query.isEmpty) {
      if (state.filteredChats != null) {
        state.filteredChats = null;
        emit(state.copyWith(filteredChats: state.filteredChats));
      }
      return;
    }

    final String loweredQuery = query.toLowerCase();
    final List<ChatEntity> baseChats = _chatsForCurrentFolder();
    final List<ChatEntity> filtered = baseChats.where((chat) {
      final bool matchesTitle = chat.displayTitle.toLowerCase().contains(loweredQuery);
      return matchesTitle;
    }).toList();

    emit(state.copyWith(filteredChats: filtered));
  }

  void _sortChats() {
    final chats = [...state.chats];
    final pinnedByChatId = {
      for (final pinned in state.pinnedChats) pinned.chatId: pinned,
    };

    final pinnedChats = <ChatEntity>[];
    final regularChats = <ChatEntity>[];

    for (final chat in chats) {
      final pinnedMeta = pinnedByChatId[chat.id];
      if (pinnedMeta != null) {
        pinnedChats.add(chat.copyWith(isPinned: true));
      } else {
        regularChats.add(chat.copyWith(isPinned: false));
      }
    }

    int comparePinnedMeta(PinnedChatEntity? a, PinnedChatEntity? b) {
      final bool aPinned = a != null;
      final bool bPinned = b != null;
      if (aPinned && !bPinned) return -1;
      if (!aPinned && bPinned) return 1;
      if (!aPinned && !bPinned) return 0;

      final int? aOrder = a!.orderIndex;
      final int? bOrder = b!.orderIndex;

      if (aOrder != null && bOrder != null && aOrder != bOrder) {
        return aOrder.compareTo(bOrder);
      }
      if (aOrder != null && bOrder == null) return -1;
      if (aOrder == null && bOrder != null) return 1;

      return b!.pinnedAt.compareTo(a.pinnedAt);
    }

    pinnedChats.sort((a, b) {
      final result = comparePinnedMeta(pinnedByChatId[a.id], pinnedByChatId[b.id]);
      if (result != 0) return result;
      return b.lastMessageDate.compareTo(a.lastMessageDate);
    });

    regularChats.sort((a, b) {
      final aHasUnread = a.unreadMessages.isNotEmpty;
      final bHasUnread = b.unreadMessages.isNotEmpty;
      if (aHasUnread && !bHasUnread) return -1;
      if (bHasUnread && !aHasUnread) return 1;
      return b.lastMessageDate.compareTo(a.lastMessageDate);
    });
    final result = [...pinnedChats, ...regularChats];
    emit(state.copyWith(chats: result));
    _applySearchFilter();
  }
}
