import 'dart:async';
import 'dart:developer';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/colors.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/enums/chat_type.dart';
import 'package:genesis_workspace/core/enums/folder_system_type.dart';
import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/subscription_op.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/data/messages/dto/narrow_operator.dart';
import 'package:genesis_workspace/data/users/dto/update_subscription_settings_dto.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_entity.dart';
import 'package:genesis_workspace/domain/all_chats/entities/pinned_chat_entity.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/add_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/delete_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_folder_ids_for_chat_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_folders_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_members_for_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_pinned_chats_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/pin_chat_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/set_folders_for_chat_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/unpin_chat_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/update_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/update_pinned_chat_order_use_case.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/mark_as_read_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_narrow_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/mark_stream_as_read_use_case.dart';
import 'package:genesis_workspace/domain/messages/usecases/mark_topic_as_read_use_case.dart';
import 'package:genesis_workspace/domain/messenger/entities/pinned_chat_order_update.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/delete_message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/subscription_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_event_entity.dart';
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

@LazySingleton()
class MessengerCubit extends Cubit<MessengerState> {
  final AddFolderUseCase _addFolderUseCase;
  final GetFoldersUseCase _getFoldersUseCase;
  final UpdateFolderUseCase _updateFolderUseCase;
  final DeleteFolderUseCase _deleteFolderUseCase;
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
  bool _prioritizePersonalUnread = false;
  bool _prioritizeUnmutedUnreadChannels = false;

  MessengerCubit(
    this._addFolderUseCase,
    this._getFoldersUseCase,
    this._updateFolderUseCase,
    this._deleteFolderUseCase,
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
    this._markStreamAsReadUseCase,
    this._markTopicAsReadUseCase,
  ) : super(
        MessengerState.initial,
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
        if (chat.type == ChatType.channel) {
          final subscription = state.subscribedChannels.firstWhere(
            (subscription) => subscription.streamId == chat.streamId,
            orElse: SubscriptionEntity.fake,
          );
          chat = chat.copyWith(
            colorString: subscription.color,
            isMuted: subscription.isMuted,
          );
        }
        final updatedChat = chat.updateLastMessage(message, isMyMessage: isMyMessage);
        chats[indexOfChat] = updatedChat;
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
          chat = chat.copyWith(
            colorString: subscription.color,
            isMuted: subscription.isMuted,
          );
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
      _oldestMessageId = response.messages.first.id;
      _lastMessageId = response.messages.last.id;
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
    if (!state.foundOldestMessage && _loadingTimes < 5) {
      try {
        final body = MessagesRequestEntity(
          anchor: MessageAnchor.id(_oldestMessageId),
          numBefore: 5000,
          numAfter: 0,
          includeAnchor: false,
        );
        final response = await _getMessagesUseCase.call(body);
        _oldestMessageId = response.messages.first.id;
        final foundOldest = response.foundOldest;
        final messages = [...state.messages];
        messages.addAll(response.messages);
        emit(
          state.copyWith(
            messages: messages,
            foundOldestMessage: _loadingTimes == 5 ? true : foundOldest,
          ),
        );
        _createChatsFromMessages(messages);
        await getPinnedChats();
        _sortChats();
        _loadingTimes += 1;
        _loadUnreadMessagesForFolders();
        await lazyLoadAllMessages();
      } catch (e) {
        if (kDebugMode) {
          inspect(e);
        }
      }
    }
  }

  Future<void> getMessagesAfterLoseConnection() async {
    final organizationId = AppConstants.selectedOrganizationId;
    final connection = _realTimeService.activeConnections[organizationId];
    if (connection?.isActive ?? false) return;
    try {
      final messagesBody = MessagesRequestEntity(
        anchor: MessageAnchor.id(_lastMessageId),
        numBefore: 0,
        numAfter: 5000,
        includeAnchor: false,
      );
      final response = await _getMessagesUseCase.call(messagesBody);
      final updatedMessages = {...state.messages, ...response.messages}.toList();
      emit(state.copyWith(messages: updatedMessages));
      _createChatsFromMessages(updatedMessages);
      _sortChats();
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }

  Future<void> getUnreadMessages() async {
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
      _createChatsFromMessages(updatedMessages);
      _sortChats();
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }

  Future<void> getPinnedChats() async {
    if (state.folders.isEmpty || state.selectedFolderIndex >= state.folders.length) {
      emit(state.copyWith(pinnedChats: []));
      return;
    }

    final folder = state.folders[state.selectedFolderIndex];

    try {
      final pins = await _getPinnedChatsUseCase.call(folder.uuid);
      emit(state.copyWith(pinnedChats: pins));
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
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

  Future<void> readAllMessagesInChannel(int streamId) async {
    try {
      await _markStreamAsReadUseCase.call(MarkStreamAsReadRequestEntity(streamId: streamId));
      final chat = state.chats.firstWhere((chat) => chat.streamId == streamId);
      final indexOfChat = state.chats.indexOf(chat);
      final updatedChat = chat.copyWith(unreadMessages: {});
      final updatedChats = [...state.chats];
      updatedChats[indexOfChat] = updatedChat;
      emit(state.copyWith(chats: updatedChats));
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }

  Future<void> readAllMessagesInTopic({required int streamId, required String topicName}) async {
    try {
      await _markTopicAsReadUseCase.call(
        MarkTopicAsReadRequestEntity(
          streamId: streamId,
          topicName: topicName,
        ),
      );
      final chat = state.chats.firstWhere((chat) => chat.streamId == streamId);
      final indexOfChat = state.chats.indexOf(chat);
      final topic = chat.topics!.firstWhere((topic) => topic.name == topicName);
      final indexOfTopic = chat.topics!.indexOf(topic);
      final updatedTopic = topic.copyWith(unreadMessages: {});
      chat.topics![indexOfTopic] = updatedTopic;
      final updatedChats = [...state.chats];
      updatedChats[indexOfChat] = chat;
      emit(state.copyWith(chats: updatedChats));
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }

  void selectChat(ChatEntity chat, {String? selectedTopic}) {
    if (selectedTopic == null) {
      emit(state.copyWith(selectedChat: chat, selectedTopic: null));
    } else {
      emit(state.copyWith(selectedChat: chat, selectedTopic: selectedTopic));
    }
  }

  void openChatFromMessage(MessageEntity message) {
    final chat = state.chats.firstWhereOrNull((chat) => chat.id == message.recipientId);
    if (chat != null) {
      selectChat(chat);
    } else {
      _createChatsFromMessages([message]);
      final createdChat = state.chats.firstWhere((chat) => chat.id == message.recipientId);
      selectChat(createdChat, selectedTopic: message.subject);
    }
  }

  Future<void> loadFolders() async {
    try {
      final int? organizationId = AppConstants.selectedOrganizationId;
      if (organizationId == null) {
        return;
      }

      final List<FolderEntity> folders = await _getFoldersUseCase.call(organizationId);
      List<FolderEntity> initialFolders = [...folders];
      if (folders.isEmpty) {
        final allFolderBody = CreateFolderEntity(
          title: "All",
          backgroundColor: AppColors.primary,
          systemType: FolderSystemType.all,
        );
        final allFolder = await _addFolderUseCase.call(allFolderBody);
        initialFolders = [allFolder, ...folders];
      }
      emit(state.copyWith(folders: initialFolders, selectedFolderIndex: 0));
      await _loadFoldersMembers();
      await getPinnedChats();
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }

  Future<void> _loadFoldersMembers() async {
    final futures = state.folders.map((folder) async {
      final folderItems = await _getMembersForFolderUseCase.call(folder.uuid);
      final updatedItems = {...folder.folderItems, ...folderItems.chatIds};
      return folder.copyWith(folderItems: updatedItems);
    }).toList();

    final updatedFolders = await Future.wait(futures);
    emit(state.copyWith(folders: updatedFolders));
  }

  void _loadUnreadMessagesForFolders() {
    if (state.folders.isEmpty) {
      return;
    }
    final updatedFolders = _recalculateUnreadMessagesForFolders(
      folders: state.folders,
      chats: state.chats,
    );
    emit(state.copyWith(folders: updatedFolders));
  }

  List<FolderEntity> _recalculateUnreadMessagesForFolders({
    required List<FolderEntity> folders,
    required List<ChatEntity> chats,
  }) {
    if (folders.isEmpty) {
      return folders;
    }

    final unreadByFolderIndex = List.generate(folders.length, (_) => <int>{});

    for (final chat in chats) {
      for (var i = 0; i < folders.length; i++) {
        final folder = folders[i];
        if (folder.systemType == .all || folder.folderItems.contains(chat.id)) {
          unreadByFolderIndex[i].addAll(chat.unreadMessages);
        }
      }
    }

    final updatedFolders = <FolderEntity>[];
    for (var i = 0; i < folders.length; i++) {
      updatedFolders.add(
        folders[i].copyWith(unreadMessages: unreadByFolderIndex[i].toList()),
      );
    }

    return updatedFolders;
  }

  Future<void> addFolder(CreateFolderEntity folder) async {
    try {
      emit(state.copyWith(isFolderSaving: true));
      final createdFolder = await _addFolderUseCase.call(folder);
      final updatedFolders = [...state.folders];
      updatedFolders.add(createdFolder);
      emit(state.copyWith(folders: updatedFolders));
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    } finally {
      emit(state.copyWith(isFolderSaving: false));
    }
  }

  void selectFolder(int newIndex) async {
    if (state.selectedFolderIndex == newIndex) return;
    emit(state.copyWith(selectedFolderIndex: newIndex));
    _filterChatsByFolder();
    await getPinnedChats();
    _sortChats();
  }

  Future<void> setFoldersForChat(List<String> foldersIds, int chatId) async {
    try {
      await _setFoldersForChatUseCase.call(
        chatId,
        foldersIds,
      );

      final foldersIdsSet = foldersIds.toSet();
      final updatedFolders = <FolderEntity>[];
      for (final folder in state.folders) {
        if (folder.systemType == FolderSystemType.all) {
          updatedFolders.add(folder);
          continue;
        }

        final updatedItems = {...folder.folderItems};
        if (foldersIdsSet.contains(folder.uuid)) {
          updatedItems.add(chatId);
        } else {
          updatedItems.remove(chatId);
        }
        updatedFolders.add(folder.copyWith(folderItems: updatedItems));
      }

      emit(
        state.copyWith(
          folders: _recalculateUnreadMessagesForFolders(
            folders: updatedFolders,
            chats: state.chats,
          ),
        ),
      );

      _filterChatsByFolder();
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }

  Future<void> updateFolder(UpdateFolderEntity folder) async {
    final updatedFolders = [...state.folders];
    final index = updatedFolders.indexWhere((element) => element.uuid == folder.uuid);
    if (index == -1) return;

    emit(state.copyWith(isFolderSaving: true));
    try {
      final updatedFolder = await _updateFolderUseCase.call(folder);
      updatedFolders[index] = updatedFolder;
      emit(state.copyWith(folders: updatedFolders));
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    } finally {
      emit(state.copyWith(isFolderSaving: false));
    }
  }

  Future<void> deleteFolder(FolderEntity folder) async {
    if (folder.systemType == FolderSystemType.all) return;

    final updatedFolders = [...state.folders];
    final index = updatedFolders.indexWhere((element) => element.uuid == folder.uuid);
    if (index == -1) return;

    emit(state.copyWith(isFolderDeleting: true));
    try {
      await _deleteFolderUseCase.call(DeleteFolderEntity(folderId: folder.uuid));
      updatedFolders.removeAt(index);
      emit(
        state.copyWith(
          folders: updatedFolders,
        ),
      );
      selectFolder(0);
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    } finally {
      emit(state.copyWith(isFolderDeleting: false));
    }
  }

  Future<List<String>> getFolderIdsForChat(int chatId) async {
    final response = await _getFolderIdsForChatUseCase.call(chatId);
    return response;
  }

  void searchChats(String query) {
    _searchQuery = query.trim();
    _applySearchFilter();
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
      if (kDebugMode) {
        inspect(e);
      }
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
      if (state.selectedFolderIndex >= state.folders.length) return;
      final folder = state.folders[state.selectedFolderIndex];
      await _pinChatUseCase.call(
        folderUuid: folder.uuid,
        chatId: chatId,
      );
      final pinnedChats = await _getPinnedChatsUseCase.call(folder.uuid);
      emit(state.copyWith(pinnedChats: pinnedChats));
      _sortChats();
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }

  Future<void> unpinChat(int chatId) async {
    try {
      if (state.selectedFolderIndex >= state.folders.length) return;
      final folder = state.folders[state.selectedFolderIndex];
      await _unpinChatUseCase.call(
        folderUuid: folder.uuid,
        chatId: chatId,
      );
      final pinnedChats = await _getPinnedChatsUseCase.call(folder.uuid);
      emit(state.copyWith(pinnedChats: pinnedChats));
      _sortChats();
    } catch (e) {
      if (kDebugMode) {
        inspect(e);
      }
    }
  }

  Future<void> reorderPinnedChats({
    required String folderUuid,
    required List<PinnedChatOrderUpdate> updates,
  }) async {
    if (updates.isEmpty) return;
    try {
      for (final update in updates) {
        await _updatePinnedChatOrderUseCase.call(
          folderUuid: folderUuid,
          folderItemUuid: update.folderItemUuid,
          orderIndex: update.orderIndex,
        );
      }

      final refreshedPins = await _getPinnedChatsUseCase.call(folderUuid);
      emit(state.copyWith(pinnedChats: refreshedPins));
      _sortChats();
    } catch (e, _) {
      // обработка/логирование
    }
  }

  void resetState() {
    _searchQuery = '';
    emit(MessengerState.initial);
    _onProfileStateChanged(_profileCubit.state);
  }

  void applyChatSortingPreferences({
    required bool prioritizePersonalUnread,
    required bool prioritizeUnmutedUnreadChannels,
  }) {
    final bool hasChanges =
        _prioritizePersonalUnread != prioritizePersonalUnread ||
        _prioritizeUnmutedUnreadChannels != prioritizeUnmutedUnreadChannels;
    _prioritizePersonalUnread = prioritizePersonalUnread;
    _prioritizeUnmutedUnreadChannels = prioritizeUnmutedUnreadChannels;
    if (hasChanges) {
      _sortChats();
    }
  }

  void _onMessageEvents(MessageEventEntity event) {
    final int? organizationId = AppConstants.selectedOrganizationId;
    if (organizationId != event.organizationId) return;
    final message = event.message.copyWith(flags: event.flags);
    _lastMessageId = message.id;

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

      /// Update lasMessagePreview for topic
      var copiedTopicList = chat.topics == null ? null : List.of(chat.topics!);
      if (copiedTopicList != null) {
        final targetIndexInTopics = chat.topics!.indexWhere((it) => it.name == event.message.subject);
        if (targetIndexInTopics != -1) {
          final targetTopic = chat.topics![targetIndexInTopics];
          final updatedTopic = targetTopic.copyWith(lastMessagePreview: messagePreview);
          copiedTopicList[targetIndexInTopics] = updatedTopic;
        }
      }

      updatedChat = updatedChat.copyWith(
        lastMessageId: message.id,
        lastMessageSenderName: messageSenderName,
        lastMessagePreview: messagePreview,
        lastMessageDate: messageDate,
        topics: copiedTopicList,
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
    final updatedFolders = _recalculateUnreadMessagesForFolders(
      folders: state.folders,
      chats: updatedChats,
    );
    emit(
      state.copyWith(
        messages: updatedMessages,
        chats: updatedChats,
        unreadMessages: updatedUnreadMessages,
        folders: updatedFolders,
      ),
    );
    _sortChats();
  }

  void _onMessageFlagsEvents(UpdateMessageFlagsEventEntity event) {
    final int? organizationId = AppConstants.selectedOrganizationId;
    if (organizationId != event.organizationId) return;

    final Set<int> affectedIds = event.all
        ? state.messages.map((message) => message.id).toSet()
        : event.messages.toSet();

    if (affectedIds.isEmpty) return;

    final String flagName = event.flag.name;
    final bool isReadFlag = event.flag == MessageFlag.read;

    final updatedMessages = state.messages.map((message) {
      if (!affectedIds.contains(message.id)) return message;

      final List<String> nextFlags = [...?message.flags];
      if (event.op == UpdateMessageFlagsOp.add) {
        if (!nextFlags.contains(flagName)) {
          nextFlags.add(flagName);
        }
      } else {
        nextFlags.remove(flagName);
      }
      return message.copyWith(flags: nextFlags);
    }).toList();

    final Map<int, MessageEntity> affectedMessages = {
      for (final message in updatedMessages.where((message) => affectedIds.contains(message.id))) message.id: message,
    };

    List<MessageEntity> updatedUnreadMessages = state.unreadMessages;
    List<ChatEntity> updatedChats = state.chats;
    List<FolderEntity> updatedFolders = state.folders;

    if (isReadFlag) {
      updatedUnreadMessages = updatedMessages.where((message) => message.isUnread).toList();
      updatedChats = state.chats.map((chat) {
        final Set<int> idsForChat = affectedMessages.values
            .where((message) => message.recipientId == chat.id)
            .map((message) => message.id)
            .toSet();
        if (idsForChat.isEmpty) return chat;

        final Set<int> unread = {...chat.unreadMessages};
        if (event.op == UpdateMessageFlagsOp.add) {
          unread.removeAll(idsForChat);
        } else {
          unread.addAll(idsForChat);
        }

        List<TopicEntity>? updatedTopics = chat.topics;
        if (chat.topics != null) {
          updatedTopics = chat.topics!.map((topic) {
            final Set<int> idsForTopic = affectedMessages.values
                .where((message) => message.recipientId == chat.id && message.subject == topic.name)
                .map((message) => message.id)
                .toSet();
            if (idsForTopic.isEmpty) return topic;

            final Set<int> topicUnread = {...topic.unreadMessages};
            if (event.op == UpdateMessageFlagsOp.add) {
              topicUnread.removeAll(idsForTopic);
            } else {
              topicUnread.addAll(idsForTopic);
            }
            return topic.copyWith(unreadMessages: topicUnread);
          }).toList();
        }

        return chat.copyWith(
          unreadMessages: unread,
          topics: updatedTopics,
        );
      }).toList();
      updatedFolders = _recalculateUnreadMessagesForFolders(
        folders: state.folders,
        chats: updatedChats,
      );
    }

    emit(
      state.copyWith(
        messages: updatedMessages,
        chats: updatedChats,
        unreadMessages: updatedUnreadMessages,
        folders: updatedFolders,
      ),
    );
  }

  void _onSubscriptionEvents(SubscriptionEventEntity event) {
    final int? organizationId = AppConstants.selectedOrganizationId;
    if (organizationId != event.organizationId) return;
    if (event.op == SubscriptionOp.update && event.property == SubscriptionProperty.isMuted) {
      List<ChatEntity> updatedChats = [...state.chats];
      ChatEntity chat = updatedChats.firstWhere((chat) => chat.streamId == event.streamId);
      final indexOfChat = updatedChats.indexOf(chat);
      chat = chat.copyWith(isMuted: event.value.raw == true);
      updatedChats[indexOfChat] = chat;
      emit(state.copyWith(chats: updatedChats));
      _sortChats();
    }
  }

  void _onDeleteEvents(DeleteMessageEventEntity event) {
    final int? organizationId = AppConstants.selectedOrganizationId;
    if (organizationId != event.organizationId) return;

    final messageId = event.messageId;

    List<ChatEntity> updatedChats = [...state.chats];
    List<MessageEntity> updatedMessages = [...state.messages];
    List<MessageEntity> updatedUnreadMessages = [...state.unreadMessages];

    final message = state.messages.firstWhere((message) => message.id == messageId, orElse: MessageEntity.fake);

    ChatEntity updatedChat = updatedChats.firstWhere((chat) => chat.id == message.recipientId);

    updatedMessages.removeWhere((message) => message.id == messageId);
    emit(state.copyWith(messages: updatedMessages));

    final List<MessageEntity> chatMessages =
        state.messages.where((message) => message.recipientId == updatedChat.id).toList()
          ..sort((firstMessage, secondMessage) => firstMessage.timestamp.compareTo(secondMessage.timestamp));

    updatedUnreadMessages.removeWhere((message) => message.id == messageId);

    if (chatMessages.length == 1) {
      updatedChats.removeWhere((chat) => chat.id == updatedChat.id);
      final updatedFolders = _recalculateUnreadMessagesForFolders(
        folders: state.folders,
        chats: updatedChats,
      );
      emit(
        state.copyWith(
          chats: updatedChats,
          unreadMessages: updatedUnreadMessages,
          messages: updatedMessages,
          folders: updatedFolders,
        ),
      );
      return;
    }

    final prevMessage = chatMessages[chatMessages.length - 1];
    _lastMessageId = prevMessage.id;

    final indexOfChat = state.chats.indexOf(updatedChat);
    updatedChat.unreadMessages.remove(messageId);
    updatedChat.topics?.forEach((topic) {
      topic.unreadMessages.remove(messageId);
    });
    updatedChat = updatedChat.updateLastMessage(
      prevMessage,
      isMyMessage: prevMessage.isMyMessage(state.selfUser?.userId),
      forceUpdateLastMessage: true,
    );
    if (updatedChat.topics?.any((topic) => topic.name == message.subject) ?? false) {
      final topic = updatedChat.topics!.firstWhere((topic) => topic.name == message.subject);
      final indexOfTopic = updatedChat.topics!.indexOf(topic);
      updatedChat.topics![indexOfTopic].unreadMessages.remove(message.id);
      final updatedTopic = updatedChat.topics![indexOfTopic].copyWith(
        lastMessageSenderName: prevMessage.senderFullName,
        lastMessagePreview: prevMessage.content,
      );
      updatedChat.topics![indexOfTopic] = updatedTopic;
    }
    updatedChats[indexOfChat] = updatedChat;
    final updatedFolders = _recalculateUnreadMessagesForFolders(
      folders: state.folders,
      chats: updatedChats,
    );
    emit(
      state.copyWith(
        chats: updatedChats,
        unreadMessages: updatedUnreadMessages,
        folders: updatedFolders,
      ),
    );
  }

  void _onUpdateMessageEvents(UpdateMessageEventEntity event) {
    final int? organizationId = AppConstants.selectedOrganizationId;
    if (organizationId != event.organizationId) return;

    final messageId = event.messageId;
    final message = state.messages.firstWhereOrNull((message) => message.id == messageId);

    if (message != null) {
      final updatedChats = [...state.chats];
      ChatEntity updatedChat = updatedChats.firstWhere((chat) => chat.id == message.recipientId);
      final indexOfChat = updatedChats.indexOf(updatedChat);
      if (updatedChat.lastMessageId == messageId) {
        updatedChat = updatedChat.copyWith(
          lastMessageId: message.id,
          lastMessageDate: message.messageDate,
          lastMessageSenderName: message.senderFullName,
          lastMessagePreview: event.content,
        );
        updatedChats[indexOfChat] = updatedChat;
      }

      List<MessageEntity> updatedMessages = [...state.messages];
      List<MessageEntity> updatedUnreadMessages = [...state.unreadMessages];

      final updatedMessage = message.copyWith(content: event.content);

      final indexOfMessage = state.messages.indexOf(message);
      updatedMessages[indexOfMessage] = updatedMessage;
      if (message.isUnread) {
        final indexOfUnreadMessage = state.unreadMessages.indexOf(message);
        if (indexOfUnreadMessage != -1) {
          updatedUnreadMessages[indexOfUnreadMessage] = updatedMessage;
        }
      }
      emit(
        state.copyWith(
          messages: updatedMessages,
          unreadMessages: updatedUnreadMessages,
          chats: updatedChats,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _messagesEventsSubscription.cancel();
    _messageFlagsEventsSubscription.cancel();
    _profileStateSubscription.cancel();
    _subscriptionEventsSubscription.cancel();
    _deleteMessageEventsSubscription.cancel();
    _updateMessageEventsSubscription.cancel();
    return super.close();
  }

  void _filterChatsByFolder() {
    Set<int>? filteredIds;

    if (state.folders.isNotEmpty && state.selectedFolderIndex > 0 && state.selectedFolderIndex < state.folders.length) {
      final folder = state.folders[state.selectedFolderIndex];
      filteredIds = folder.folderItems;
    }
    emit(state.copyWith(filteredChatIds: filteredIds));
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
        emit(state.copyWith(filteredChats: null));
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

  bool _isPersonalChat(ChatEntity chat) => chat.type == ChatType.direct || chat.type == ChatType.groupDirect;

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

      final int? aOrder = a?.orderIndex;
      final int? bOrder = b?.orderIndex;

      if (aOrder != null && bOrder != null && aOrder != bOrder) {
        return aOrder.compareTo(bOrder);
      }
      if (aOrder != null && bOrder == null) return -1;
      if (aOrder == null && bOrder != null) return 1;

      final DateTime aUpdatedAt = a?.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime bUpdatedAt = b?.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bUpdatedAt.compareTo(aUpdatedAt);
    }

    pinnedChats.sort((a, b) {
      final result = comparePinnedMeta(pinnedByChatId[a.id], pinnedByChatId[b.id]);
      if (result != 0) return result;
      return b.lastMessageDate.compareTo(a.lastMessageDate);
    });

    regularChats.sort((a, b) {
      final bool aHasUnread = a.unreadMessages.isNotEmpty;
      final bool bHasUnread = b.unreadMessages.isNotEmpty;

      if (_prioritizePersonalUnread && aHasUnread && bHasUnread) {
        final bool aIsPersonal = _isPersonalChat(a);
        final bool bIsPersonal = _isPersonalChat(b);
        if (aIsPersonal && !bIsPersonal) return -1;
        if (bIsPersonal && !aIsPersonal) return 1;
      }

      if (_prioritizeUnmutedUnreadChannels && aHasUnread && bHasUnread) {
        final bool aIsChannel = a.type == ChatType.channel;
        final bool bIsChannel = b.type == ChatType.channel;
        if (aIsChannel && bIsChannel && a.isMuted != b.isMuted) {
          return a.isMuted ? 1 : -1;
        }
      }

      return b.lastMessageDate.compareTo(a.lastMessageDate);
    });
    final result = [...pinnedChats, ...regularChats];
    emit(state.copyWith(chats: result));
    _applySearchFilter();
  }

  void createEmptyChat(Set<int> membersIds) async {
    final newState = state.copyWith(usersIds: membersIds);
    emit(newState);
  }

  void unselectChat() {
    emit(state.copyWith(selectedChat: null, selectedTopic: null));
  }
}
