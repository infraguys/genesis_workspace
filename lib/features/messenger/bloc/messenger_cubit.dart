import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genesis_workspace/core/config/constants.dart';
import 'package:genesis_workspace/core/enums/message_flag.dart';
import 'package:genesis_workspace/core/enums/update_message_flags_op.dart';
import 'package:genesis_workspace/domain/all_chats/entities/folder_members.dart';
import 'package:genesis_workspace/domain/all_chats/entities/pinned_chat_entity.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/add_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/delete_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_folders_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_members_for_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/get_pinned_chats_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/pin_chat_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/remove_all_memberships_for_folder_use_case.dart';
import 'package:genesis_workspace/domain/all_chats/usecases/unpin_chat_use_case.dart';
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
  final PinChatUseCase _pinChatUseCase;
  final UnpinChatUseCase _unpinChatUseCase;
  final GetPinnedChatsUseCase _getPinnedChatsUseCase;

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
    this._pinChatUseCase,
    this._unpinChatUseCase,
    this._getPinnedChatsUseCase,
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
          pinnedChats: [],
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
      await getPinnedChats();
      emit(
        state.copyWith(
          messages: messages,
          unreadMessages: unreadMessages,
        ),
      );
      _sortChats(chats);
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
    response.forEach((pinnedChat) {
      if (state.chats.any((chat) => chat.id == pinnedChat.chatId)) {
        final chat = state.chats.firstWhere((chat) => chat.id == pinnedChat.chatId);
        final indexOfChat = state.chats.indexOf(chat);
        final updatedChat = chat.copyWith(isPinned: true);
        updatedChats[indexOfChat] = updatedChat;
      }
    });
    emit(state.copyWith(pinnedChats: response, chats: updatedChats));
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
      _sortChats(updatedChats);
    } catch (e) {
      inspect(e);
    }
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
      _sortChats(state.chats);
    } catch (e) {
      inspect(e);
    }
  }

  Future<void> unpinChat(int chatId) async {
    try {
      final int? organizationId = AppConstants.selectedOrganizationId;
      if (organizationId == null) return;

      final int folderId = state.folders[state.selectedFolderIndex].id!;
      final int pinnedChatId = state.pinnedChats
          .firstWhere((pinnedChat) => pinnedChat.chatId == chatId)
          .id;
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
      _sortChats(state.chats);
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
        if (updatedChat.topics?.any((topic) => topic.name == message.subject) ?? false) {
          final topic = updatedChat.topics!.firstWhere((topic) => topic.name == message.subject);
          final indexOfTopic = updatedChat.topics!.indexOf(topic);
          updatedChat.topics![indexOfTopic].unreadMessages.add(message.id);
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
    emit(state.copyWith(messages: updatedMessages));
    _sortChats(updatedChats);
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
        updatedChat.topics?.forEach((topic) {
          topic.unreadMessages.remove(messageId);
        });
        updatedChats[indexOfChat] = updatedChat;
      }
    }
    emit(state.copyWith(chats: updatedChats, unreadMessages: updatedUnreadMessages));
  }

  @override
  Future<void> close() {
    _messagesEventsSubscription.cancel();
    _messageFlagsEventsSubscription.cancel();
    return super.close();
  }

  void _sortChats(List<ChatEntity> chats) {
    // if (chats.isEmpty) return <ChatEntity>[];

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
  }
}
