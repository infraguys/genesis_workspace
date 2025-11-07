import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_members.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/add_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/delete_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_folders_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_members_for_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/remove_all_memberships_for_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/update_folder_use_case.dart';
import 'package:genesis_workspace/domain/chats/entities/chat_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/message_entity.dart';
import 'package:genesis_workspace/domain/messages/entities/messages_request_entity.dart';
import 'package:genesis_workspace/domain/messages/usecases/get_messages_use_case.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/message_event_entity.dart';
import 'package:genesis_workspace/domain/real_time_events/entities/event/update_message_flags_event_entity.dart';
import 'package:genesis_workspace/domain/users/entities/folder_item_entity.dart';
import 'package:genesis_workspace/domain/users/entities/topic_entity.dart';
import 'package:genesis_workspace/domain/users/entities/user_entity.dart';
import 'package:genesis_workspace/domain/users/usecases/get_topics_use_case.dart';
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

  final MultiPollingService _realTimeService;

  late final StreamSubscription<MessageEventEntity> _messagesEventsSubscription;
  late final StreamSubscription<UpdateMessageFlagsEventEntity> _messageFlagsEventsSubscription;

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
  ) : super(
        MessengerState(
          selfUser: null,
          folders: [],
          selectedFolderIndex: 0,
          folderMembersById: const {},
          messages: [],
          unreadMessages: [],
          chats: [],
          selectedChat: null,
        ),
      ) {
    _messagesEventsSubscription = _realTimeService.messageEventsStream.listen(_onMessageEvents);
    _messageFlagsEventsSubscription = _realTimeService.messageFlagsEventsStream.listen(
      _onMessageFlagsEvents,
    );
  }

  Future<void> getMessages() async {
    try {
      final messagesBody = MessagesRequestEntity(
        anchor: MessageAnchor.newest(),
        narrow: [
          // MessageNarrowEntity(operator: NarrowOperator.isFilter, operand: "dm"),
        ],
        numBefore: 5000,
        numAfter: 0,
        clientGravatar: false,
      );
      final response = await _getMessagesUseCase.call(messagesBody);
      final messages = response.messages;
      final unreadMessages = [...state.unreadMessages];
      final chats = [...state.chats];
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
          final chat = ChatEntity.createChatFromMessage(
            message.copyWith(avatarUrl: isMyMessage ? null : message.avatarUrl),
            isMyMessage: isMyMessage,
          );
          chats.add(chat);
        }
      }
      emit(
        state.copyWith(
          messages: messages,
          chats: _sortChatsByLastMessageDate(chats),
          unreadMessages: unreadMessages,
        ),
      );
    } catch (e) {
      inspect(e);
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

  Future<void> addFolder(FolderItemEntity folder) async {
    try {
      await _addFolderUseCase.call(folder);
      final updatedFolders = [...state.folders];
      updatedFolders.add(folder.copyWith(id: updatedFolders.length));
      emit(state.copyWith(folders: updatedFolders));
      await _refreshAllFolderMembers();
    } catch (e) {
      inspect(e);
    }
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
          unreadCount: 0,
          pinnedChats: [],
          organizationId: organizationId,
        );
        await addFolder(initFolder);
        return;
      }
      final List<FolderItemEntity> initialFolders = [...dbFolders];
      emit(state.copyWith(folders: initialFolders, selectedFolderIndex: 0));
      await _refreshAllFolderMembers();
    } catch (e) {
      inspect(e);
    }
  }

  void selectFolder(int newIndex) async {
    if (state.selectedFolderIndex == newIndex) return;
    emit(state.copyWith(selectedFolderIndex: newIndex));
    // FolderItemEntity folder = state.folders[newIndex];
    // if (folder.id == null) {
    //   state.filterChannelIds = null;
    //   state.filterDmUserIds = null;
    //   state.filterGroupChatIds = null;
    //   emit(
    //     state.copyWith(
    //       filterDmUserIds: state.filterDmUserIds,
    //       filterChannelIds: state.filterChannelIds,
    //       filterGroupChatIds: state.filterGroupChatIds,
    //     ),
    //   );
    //   return;
    // }
    // final members = await _getMembersForFolderUseCase.call(folder.id!);
    // emit(
    // state.copyWith(
    // filterDmUserIds: members.dmUserIds.toSet(),
    // filterChannelIds: members.channelIds.toSet(),
    // filterGroupChatIds: members.groupChatIds.toSet(),
    // ),
    // );
  }

  Future<void> updateFolder(FolderItemEntity folder) async {
    if (folder.systemType != null || folder.id == null) return;
    final updatedFolders = [...state.folders];
    final index = updatedFolders.indexWhere((element) => element.id == folder.id);
    await _updateFolderUseCase.call(folder);
    updatedFolders[index] = folder;
    emit(state.copyWith(folders: updatedFolders));
    await _refreshMembersForFolders([folder.id!]);
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
    final updatedMap = Map<int, FolderMembers>.from(state.folderMembersById);
    updatedMap.remove(folder.id!);
    emit(
      state.copyWith(
        folders: updatedFolders,
        folderMembersById: updatedMap,
        selectedFolderIndex: 0,
      ),
    );
  }

  Future<void> _refreshMembersForFolders(Iterable<int> folderIds) async {
    final int? organizationId = AppConstants.selectedOrganizationId;
    if (organizationId == null) return;
    final idsToRefresh = folderIds.where((id) => id != 0);
    if (idsToRefresh.isEmpty) return;

    final futures = idsToRefresh.map((id) async {
      final members = await _getMembersForFolderUseCase.call(id, organizationId: organizationId);
      return MapEntry(id, members);
    });

    final newEntries = await Future.wait(futures);
    final updatedMap = Map<int, FolderMembers>.from(state.folderMembersById)
      ..addEntries(newEntries);

    emit(state.copyWith(folderMembersById: updatedMap));
  }

  Future<void> _refreshAllFolderMembers() async {
    final int? organizationId = AppConstants.selectedOrganizationId;
    if (organizationId == null) return;
    final foldersToRefresh = state.folders.where((f) => f.id != null && f.id != 0);
    final futures = foldersToRefresh.map((f) async {
      final members = await _getMembersForFolderUseCase.call(f.id!, organizationId: organizationId);
      return MapEntry(f.id!, members);
    });
    final entries = await Future.wait(futures);
    emit(state.copyWith(folderMembersById: Map.fromEntries(entries)));
  }

  void setSelfUser(UserEntity user) {
    emit(state.copyWith(selfUser: user));
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
      emit(state.copyWith(chats: _sortChatsByLastMessageDate(updatedChats)));
    } catch (e) {
      inspect(e);
    }
  }

  void resetState() {
    emit(
      state.copyWith(
        folders: [],
        selectedFolderIndex: 0,
        folderMembersById: const {},
        messages: [],
        chats: [],
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
    final sortedChats = _sortChatsByLastMessageDate(updatedChats);
    emit(state.copyWith(messages: updatedMessages, chats: sortedChats));
  }

  void _onMessageFlagsEvents(UpdateMessageFlagsEventEntity event) {
    final int? organizationId = AppConstants.selectedOrganizationId;
    if (organizationId != event.organizationId) return;
    List<ChatEntity> updatedChats = [...state.chats];
    List<MessageEntity> updatedUnreadMessages = [...state.unreadMessages];
    if (event.op == UpdateMessageFlagsOp.add && event.flag == MessageFlag.read) {
      for (final messageId in event.messages) {
        updatedUnreadMessages.removeWhere((message) => message.id == messageId);
        final message = state.messages.firstWhere((message) => message.id == messageId);
        ChatEntity updatedChat = updatedChats.firstWhere((chat) => chat.id == message.recipientId);
        final indexOfChat = state.chats.indexOf(updatedChat);
        updatedChat.unreadMessages.remove(messageId);
        updatedChats[indexOfChat] = updatedChat;
      }
    }
    emit(state.copyWith(chats: updatedChats, unreadMessages: updatedUnreadMessages));
  }

  @override
  Future<void> close() {
    _messagesEventsSubscription.cancel();
    return super.close();
  }

  List<ChatEntity> _sortChatsByLastMessageDate(List<ChatEntity> chats) {
    final sortedChats = [...chats];
    sortedChats.sort((a, b) {
      final aHasUnread = a.unreadMessages.isNotEmpty;
      final bHasUnread = b.unreadMessages.isNotEmpty;
      if (aHasUnread && !bHasUnread) return -1;
      if (bHasUnread && !aHasUnread) return 1;
      return b.lastMessageDate.compareTo(a.lastMessageDate);
    });
    return sortedChats;
  }
}
